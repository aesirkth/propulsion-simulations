% This file is where one can run single simulation that plots in greater detail


setup();
run assumptions


% Set the mass flow to simulate
massFlow = 2.5;

flightOpts = computeDerivedFlightOpts(struct( ...
    'OxidizerFuelRatio', ofRatio, ...
    'ParachuteMass', parachuteMass, ...
    'ElectronicsMass', electronicsMass, ...
    'BodyTubeMass', bodyTubeMass, ...
    'PayloadMass', payloadMass, ...
    'PropellantMass', propellantMass, ...
    'TankPressure', tankPressure, ...
    'CombustionPressure', combustionPressure, ...
    'Radius', (rocketDiameterInCentimeters/100)/2, ...
    'FuelGrainRadius', (fuelGrainDiameterInCentimeters/100)/2, ...
    'ExpansionPressure', expansionPressureInAtmospheres * 101300, ...
    'ExhaustDiameter', diameterOfNozzleExhaustInCentimeters / 100, ...
    'Isp', specificImpulse,  ...
    'MassFlow', massFlow,  ...
    'LaunchAngle', launchAngle ...
))

%%
model = @(t, y) flightModel(t, y, flightOpts);

odeOpts = odeset('Events', @flightModelEvents, 'RelTol', 1e-8, 'AbsTol', 1e-8);
[t, State] = ode45(model, [0 500], [0 0 0 0 flightOpts.PropellantMass], odeOpts);

plotSingleSimulation(flightOpts, t, State);
