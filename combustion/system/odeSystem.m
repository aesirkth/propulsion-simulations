% The simulation system
function [dXdt,regressionRate,ccPressureVariation,oxidizerMassFlow,fuelMassFlow,thrust,ccTemperature] = odeSystem(t, X, opts)
    % X is of the form [oxidizerMass, fuelMass, portRadius, ccPressure]
    oxidizerMass = X(1);
    fuelMass = X(2);
    portRadius = X(3);
    ccPressure = X(4);
    
    % Combustion model
    [regressionRate,ccPressureVariation,oxidizerMassFlow,fuelMassFlow,cStar,ccTemperature] = combustionModel(t,portRadius, ccPressure, oxidizerMass, opts);

    % Computed mass flow
    massFlow = oxidizerMassFlow + fuelMassFlow;

    ambientPressure = 101300; % not optimal but will do for now...
    
    % Thrust Force
    thrust = thrustModel(t, massFlow, ccPressure, ambientPressure, cStar, opts);
    
    % Returning differential vector
    dXdt = [-oxidizerMassFlow;-fuelMassFlow;regressionRate;ccPressureVariation];
end
