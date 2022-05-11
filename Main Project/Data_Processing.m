%% 1. Generate the scenario
clear all

% Load in building data
London_Buildings = Processjson('zoom_16.json'); 
London_Buildings_North = Processjson('zoom_16_north.json');
London_Buildings_East = Processjson('zoom_16_east.json');
London_Buildings_NorthEast = Processjson('zoom_16_northeast.json');
All_Buildings = [London_Buildings, London_Buildings_North, London_Buildings_East, London_Buildings_NorthEast]
Silk_District = importdata('Silk_District.txt');

% Define the scenario
latloncenter = [51.51795 -0.05856 1000]; % Define centre of map
scene = uavScenario("UpdateRate",10,"StopTime",40,"ReferenceLocation",latloncenter); % Create the scene
addInertialFrame(scene,"ENU","MAP",trvec2tform(latloncenter)); 
addMesh(scene,"polygon",{[-280 -250; 250 -250; 250 300; -280 300],[-4 0]},0.651*ones(1,3)); % Add a floor mesh
used_buildings = struct;
used_buildings.coordinates = zeros(100,2);
used_buildings.height = zeros(100,1);

% Generate Silk District buildings
for i = 1:11
    building_coords = importdata(Silk_District.textdata{i});
    building_height = Silk_District.data(i);
    addMesh(scene,"Polygon",{[building_coords(:,2),building_coords(:,1)],[0 building_height]},[0 1 0],"UseLatLon",true);
end

[no_of_buildings, dimension] = size(London_Buildings.features);

% Generate central buildings
for i = 1:no_of_buildings
   
    if i ~= 218
        if London_Buildings.features(i).geometry.coordinates(:,:,1) >= -0.06221 & London_Buildings.features(i).geometry.coordinates(:,:,1) <= -0.05528 & London_Buildings.features(i).geometry.coordinates(:,:,2) >= 51.51603 & London_Buildings.features(i).geometry.coordinates(:,:,2) <= 51.52051 
        building_coords = transpose([London_Buildings.features(i).geometry.coordinates(:,:,2); London_Buildings.features(i).geometry.coordinates(:,:,1)]);
        building_height = London_Buildings.features(i).properties.height;
        end
    end

    addMesh(scene,"Polygon",{building_coords,[0 building_height]},[0 1 0],"UseLatLon",true,"ReferenceFrame","ENU");
    
end
show3D(scene)

[no_of_buildings, dimension] = size(London_Buildings_North.features);

% Generate north buildings
for i = 1:no_of_buildings
    if London_Buildings_North.features(i).geometry.coordinates(:,:,1) >= -0.06221 & London_Buildings_North.features(i).geometry.coordinates(:,:,1) <= -0.05528 & London_Buildings_North.features(i).geometry.coordinates(:,:,2) >= 51.51603 & London_Buildings_North.features(i).geometry.coordinates(:,:,2) <= 51.52051 
        building_coords = transpose([London_Buildings_North.features(i).geometry.coordinates(:,:,2); London_Buildings_North.features(i).geometry.coordinates(:,:,1)]);
        building_height = London_Buildings_North.features(i).properties.height;
        addMesh(scene,"Polygon",{building_coords,[0 building_height]},[0 1 0],"UseLatLon",true);
    end
end

[no_of_buildings, dimension] = size(London_Buildings_East.features);

% Generate east buildings
for i = 1:no_of_buildings
    if i ~= 266
        if London_Buildings_East.features(i).geometry.coordinates(:,:,1) >= -0.06221 & London_Buildings_East.features(i).geometry.coordinates(:,:,1) <= -0.05528 & London_Buildings_East.features(i).geometry.coordinates(:,:,2) >= 51.51603 & London_Buildings_East.features(i).geometry.coordinates(:,:,2) <= 51.52051 
            building_coords = transpose([London_Buildings_East.features(i).geometry.coordinates(:,:,2); London_Buildings_East.features(i).geometry.coordinates(:,:,1)]);
            building_height = London_Buildings_East.features(i).properties.height;
            addMesh(scene,"Polygon",{building_coords,[0 building_height]},[0 1 0],"UseLatLon",true);
        end
    end
end

[no_of_buildings, dimension] = size(London_Buildings_NorthEast.features);

% Generate north-east buildings
for i = 1:no_of_buildings
    if London_Buildings_NorthEast.features(i).geometry.coordinates(:,:,1) >= -0.06221 & London_Buildings_NorthEast.features(i).geometry.coordinates(:,:,1) <= -0.05528 & London_Buildings_NorthEast.features(i).geometry.coordinates(:,:,2) >= 51.51603 & London_Buildings_NorthEast.features(i).geometry.coordinates(:,:,2) <= 51.52051 
        building_coords = transpose([London_Buildings_NorthEast.features(i).geometry.coordinates(:,:,2); London_Buildings_NorthEast.features(i).geometry.coordinates(:,:,1)]);
        building_height = London_Buildings_NorthEast.features(i).properties.height;
        addMesh(scene,"Polygon",{building_coords,[0 building_height]},[0 1 0],"UseLatLon",true);
    end
end

show3D(scene)
%% 2. Generate aircraft

% Define UAV trajectory
traj1 = waypointTrajectory("Waypoints", [50 0 -50; 50 100 -50; -100 100 -50; -100 -100 -50],"TimeOfArrival",[0 2 4 6]); 
uavPlat1 = uavPlatform("UAV1",scene,"Trajectory",traj1); 
updateMesh(uavPlat1,"quadrotor", {30}, [1 0 0],eul2tform([0 0 pi])); 
addGeoFence(uavPlat1,"Polygon", {[-50 0; 50 0; 50 50; -50 50],[0 100]},true,"ReferenceFrame","ENU");

% Mount Lidar onto the UAV
lidarOrient = [90 90 0];
lidarSensor = uavLidarPointCloudGenerator("MaxRange",100,"RangeAccuracy",0.03,"ElevationLimits",[-15 15],"ElevationResolution", 2,"AzimuthLimits",[-180 180], ...
    "AzimuthResolution",0.2,"UpdateRate", 10, "HasOrganizedOutput",false);
lidar = uavSensor("Lidar",uavPlat1,lidarSensor,"MountingLocation", [0 0 -3],"MountingAngles",lidarOrient);

% Mount a radar on the UAV
radarSensor = radarDataGenerator("no scanning","SensorIndex",1,...
    "FieldOfView",[120 80],...
    "UpdateRate", 1,...
    'MountingAngles',[0 30 0],...
    "HasElevation", true,...
    "ElevationResolution", 6,...
    "AzimuthResolution", 2, ...
    "RangeResolution", 4, ...
    "RangeLimits", [0 200],...
    'ReferenceRange',200,...
    'CenterFrequency',24.55e9,...
    'Bandwidth',200e6,...
    "TargetReportFormat","Detections",...
    "DetectionCoordinates","Sensor rectangular",...
    "HasFalseAlarms",false,...
    "FalseAlarmRate", 1e-7);
radarcov = coverageConfig(radarSensor);
radar = uavSensor("Radar",uavPlat1,helperRadarAdaptor(radarSensor));

lidarDetector = helperLidarDetector(scene)

lidarJPDA = trackerJPDA('TrackerIndex',2,...
    'AssignmentThreshold',[70 150],...
    'ClutterDensity',1e-16,...
    'DetectionProbability',0.99,...
    'DeletionThreshold',[10 10],... Delete lidar track if missed for 1 second
    'ConfirmationThreshold',[4 5],...
    'FilterInitializationFcn',@initLidarFilter)

radarPHD = createRadarTracker(radarSensor, uavPlat1)

radarConfig = fuserSourceConfiguration('SourceIndex',1,...
    'IsInitializingCentralTracks',true);

lidarConfig = fuserSourceConfiguration('SourceIndex',2,...
    'IsInitializingCentralTracks',true);

fuser = trackFuser('SourceConfigurations',{radarConfig,lidarConfig},...
    'ProcessNoise',blkdiag(2*eye(6),1*eye(3),0.2*eye(4)),...
    'HasAdditiveProcessNoise',true,...
    'AssignmentThreshold',200,...
    'ConfirmationThreshold',[4 5],...
    'DeletionThreshold',[5 5],...
    'StateFusion','Cross',...
    'StateTransitionFcn',@augmentedConstvel,...
    'StateTransitionJacobianFcn',@augmentedConstvelJac);

viewer = helperUAVDisplay(scene);

ylim([-310 550])
xlim([-280 320])
zlim([0 150])

%% Setup the scene

setup(scene);
s = rng;
rng(2021);

numSteps = scene.StopTime*scene.UpdateRate;
truthlog = cell(1,numSteps);
radarlog = cell(1,numSteps);
lidarlog = cell(1,numSteps);
fusedlog = cell(1,numSteps);
logCount = 0;

while advance(scene)
    time = scene.CurrentTime;
    % Update sensor readings and read data.
    updateSensors(scene);
    egoPose = read(uavPlat1);

    % Track with radar
    [radardets, radarTracks, inforadar] = updateRadarTracker(radar,radarPHD, egoPose, time);

    % Track with lidar
    [lidardets, lidarTracks, nonGroundCloud, groundCloud] = updateLidarTracker(lidar,lidarDetector, lidarJPDA, egoPose);

    % Fuse lidar and radar tracks
    rectRadarTracks = formatPHDTracks(radarTracks);
    if isLocked(fuser) || ~isempty(radarTracks) || ~isempty(lidarTracks)
        [fusedTracks,~,allfused,info] = fuser([lidarTracks;rectRadarTracks],time);
    else
        fusedTracks = objectTrack.empty;
    end

    % Save log
    logCount = logCount + 1;
    lidarlog{logCount} = lidarTracks;
    radarlog{logCount} = rectRadarTracks;
    fusedlog{logCount} = fusedTracks;
    truthlog{logCount} = logTargetTruth(scene.Platforms(1));
    
    % Update figure
    viewer(radarcov, nonGroundCloud, groundCloud, lidardets, radardets, lidarTracks, radarTracks, fusedTracks );
end
