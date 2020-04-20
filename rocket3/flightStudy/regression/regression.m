clear
clc

ofRatio = 8;
oxidizerMassFlow = 2.1425; %massFlow * ofRatio / (ofRatio + 1);

diameterCm = 5;
finalDiameterCm = 13;
r0 = ( diameterCm / 2 ) / 1e2;
rFinal = ( finalDiameterCm / 2 ) / 1e2;

n = 0.5;
aUnit = 1e-3; %% in mm
a = 15.5e-5;
% 
% G = @(r) oxidizerMassFlow / (pi * r*r);
% rdot = @(r) a .* G(r).^n;
% 
% ode = @(t, r) rdot(r)
% 
% events = @(t, r) eventsFn(t, r, rFinal)
% 
% opts = odeset('Events', events);
% [t, r] = ode45(ode, [0 1000], [r0], opts)
% 
% plot(t, r)


rhoOxidizer = 770;
rhoFuel = 900;
pCombustion = 4.5e6;
p0 = 5e6;
p1 = p0 * 0.85;
deltaP = p0 - pCombustion;
CdA = oxidizerMassFlow / sqrt(2 * rhoOxidizer * deltaP);

fuelGrainLength = 0.37; % meters
fuelVolume = (pi*rFinal^2 - pi*r0^2) * fuelGrainLength;
fuelMass = fuelVolume * rhoFuel;
propellantMass = fuelMass * (1 + ofRatio);
oxidizerMass = propellantMass * ofRatio / (ofRatio + 1);

vars = [n, a, p0, p1, CdA, rhoOxidizer, rhoFuel, deltaP, oxidizerMassFlow, fuelGrainLength];
% [rdot, oxidizerConsumedFraction, tankPressure, combustionPressure, oxidizerFlow, fuelFlow, totalFlow, outputRatio] = system(0, [oxidizerMass fuelMass r0], [oxidizerMass fuelMass r0], vars)

S0 = [oxidizerMass fuelMass r0];
TSpan = [0 1000];

events = @(t, S) eventsFn(t, S, rFinal);
opts = odeset('Events', events, 'RelTol', 1e-10, 'AbsTol', 1e-10);

ode = @(t, S) odeFn(t, S, S0, vars);
[t, S] = ode45(ode, TSpan, S0, opts);

[r, oxidizerMass, fuelMass, rdot, oxidizerConsumedFraction, tankPressure, combustionPressure, oxidizerFlow, fuelFlow, totalFlow, outputRatio] = system(t, S, S0, vars);

oxidizerFlow(end)
fuelFlow(end)

clf
subplot(3,2,1);
plot(t, oxidizerMass, 'LineWidth', 2, 'DisplayName', 'oxidizer')
hold on
plot(t, fuelMass, 'LineWidth', 2, 'DisplayName', 'fuel')
xlabel("time (s)");
ylabel("mass (kg)");
title("Mass over time");
legend('show', 'location', 'best');
grid on

subplot(3,2,2);
plot(t, tankPressure / 1e6, 'LineWidth', 2, 'DisplayName', 'Tank pressure')
hold on
plot(t, combustionPressure / 1e6, 'LineWidth', 2, 'DisplayName', 'Combustion pressure')
title("Pressures over time");
xlabel("time (s)");
ylabel("pressure (MPa)");
legend('show', 'location', 'best');
grid on

subplot(3,2,3);
plot(t, 2*r*1e3,  'LineWidth', 2)
xlabel("time (s)");
ylabel("diameter (mm)");
title("Port diameter (mm)");
grid on

subplot(3,2,4);
plot(t, oxidizerFlow, '-', 'LineWidth', 2, 'DisplayName', 'oxidizer')
hold on
plot(t, fuelFlow, '-', 'LineWidth', 2, 'DisplayName', 'fuel')
hold on
plot(t, oxidizerFlow + fuelFlow, '--', 'LineWidth', 2, 'DisplayName', 'total')
grid on
xlabel("time (s)");
ylabel("flow (kg/s)");
legend('show', 'location', 'best');
title("Mass flow");

subplot(3,2,5);
plot(t, outputRatio, 'LineWidth', 2, 'DisplayName', 'real')
hold on
plot([t(1) t(end)], [ofRatio ofRatio], '--', 'LineWidth', 2, 'DisplayName', 'optimal')
lims = ylim;
ylim(lims + [-diff(lims) diff(lims)]*0.1);
grid on
xlabel("time (s)");
ylabel("ratio");
title("OF ratio");
legend('show', 'location', 'best');
 
function dSdt = odeFn(t, S, S0, vs)
    [~, ~, ~, rdot, ~, ~, ~, oxidizerFlow, fuelFlow, ~, ~] = system(t, S', S0, vs);
    
    dSdt = [-oxidizerFlow -fuelFlow rdot]';
end

function [r, oxidizerMass, fuelMass, rdot, oxidizerConsumedFraction, tankPressure, combustionPressure, oxidizerFlow, fuelFlow, totalFlow, outputRatio] = system(t, S, S0, vs)
    O = ones(size(S, 1), 1);
        
    n = O*vs(1);
    a = O*vs(2);
    p0 = O*vs(3);
    p1 = O*vs(4);
    CdA = O*vs(5);
    rhoOxidizer = O*vs(6);
    rhoFuel = O*vs(7);
    deltaP = O*vs(8);
    oxidizerMassFlow = O*vs(9);
    fuelGrainLength = O*vs(10);
   
    initialOxidizerMass = S0(:, 1);
    oxidizerMass = S(:, 1);
    fuelMass = S(:, 2);
    r = S(:, 3);
    
    oxidizerConsumedFraction = 1 - oxidizerMass ./ initialOxidizerMass;
    tankPressure = p0 - (p0 - p1) .* oxidizerConsumedFraction;
    
    combustionPressure = tankPressure - deltaP;
    oxidizerFlow = CdA .* sqrt(2.*rhoOxidizer.*deltaP);
    
    G = oxidizerMassFlow ./ (pi .* r .* r);
    rdot = a .* G.^n;
    
    fuelFlow = 2.*pi.*r .* fuelGrainLength .* rdot .* rhoFuel;
    
    totalFlow = oxidizerFlow + fuelFlow;
    
    outputRatio = oxidizerFlow ./ fuelFlow;
end

function [position,isterminal,direction] = eventsFn(~,S,rFinal)
    oxidizerMass = S(1);
    fuelMass = S(2);
    r = S(3);
    
    position = [oxidizerMass fuelMass (r - rFinal)]; % The value that we want to be zero
    isterminal = [1 1 1];  % Halt integration 
    direction = [0 0 0];   % The zero can be approached from either direction
end