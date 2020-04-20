opts.CombustionChamberDiameter = opts.CombustionChamberDiameterInCm / 100;
opts.CombustionChamberRadius = opts.CombustionChamberDiameter / 2;
opts.CombustionChamberWallThickness = opts.CombustionChamberWallThicknessInMm / 1000;
opts.FuelGrainContainerWallThickness = opts.FuelGrainContainerWallThicknessInMm / 1000;
opts.FuelGrainInitialPortRadius = opts.FuelGrainInitialPortRadiusInCm / 100;

opts.TotalFuelGrainRadius = opts.CombustionChamberRadius - opts.CombustionChamberWallThickness;
opts.UsableFuelGrainRadius = opts.CombustionChamberRadius - opts.CombustionChamberWallThickness - opts.FuelGrainContainerWallThickness;

opts.FuelGrainLength = opts.FuelGrainLengthInCm / 100;

% Carbon additive impacts on fuel density
opts.FuelGrainDensity = opts.FuelDensity * (1 - opts.CarbonAdditiveFraction) + opts.CarbonDensity * opts.CarbonAdditiveFraction;

opts.TotalFuelVolume = (opts.UsableFuelGrainRadius/2)^2 * pi - opts.FuelGrainInitialPortRadius^2 * pi * opts.FuelGrainLength;
opts.FuelVolume = (opts.UsableFuelGrainRadius/2)^2 * pi - opts.FuelGrainInitialPortRadius^2 * pi * opts.FuelGrainLength;
opts.UnusableFuelVolume = opts.TotalFuelVolume - opts.FuelVolume;

opts.TotalFuelMass = opts.TotalFuelVolume * opts.FuelGrainDensity;
opts.FuelMass = opts.FuelVolume * opts.FuelGrainDensity;
opts.UnusableFuelMass = opts.UnusableFuelVolume * opts.FuelGrainDensity;

opts.PropellantMass = opts.FuelMass * (1 + opts.DesignOFRatio);
opts.OxidizerMass = opts.PropellantMass * opts.DesignOFRatio / (opts.DesignOFRatio + 1);
opts.OxidizerVolume = opts.OxidizerMass / opts.OxidizerDensity;

opts.InjectorsArea = pi*(opts.InjectorsDiameter/2)^2 * opts.NumberOfInjectors;