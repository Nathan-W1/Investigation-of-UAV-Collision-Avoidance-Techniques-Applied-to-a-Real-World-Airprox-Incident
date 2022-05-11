%% 1. Generate the scenario
clear all
load HEMS1_coords.mat
load HEMS2_coords.mat
load HEMS1_times.mat
load HEMS2_times.mat
 coordvals1(:,3) = coordvals1(:,3)-70;
 coordvals1(:,1) = (coordvals1(:,1)+30)*1.5;
 coordvals1(:,2) = (coordvals1(:,2))*1.5;
 coordvals1(6,1) = coordvals1(6,1)-30;
 coordvals1(7,1) = coordvals1(7,1)-50;
 coordvals1(end,:) = [6.89354258156527,23.8554169065992,-150];
 coordvals2(:,3) = coordvals2(:,3)*-1;

 % Load in building data
load All_Buildings.mat
Silk_District = importdata('Silk_District.txt');

% Define the scenario
latloncenter = [51.51795 -0.05856 1000]; % Define centre of map
scene = uavScenario("UpdateRate",10,"StopTime",40,"ReferenceLocation",latloncenter); % Create the scene
addInertialFrame(scene,"ENU","MAP",trvec2tform(latloncenter)); 
addMesh(scene,"polygon",{[-280 -250; 250 -250; 250 300; -280 300],[-1 0]},0.651*ones(1,3)); % Add a floor mesh

for i = 1:11
    building_coords = importdata(Silk_District.textdata{i});
    building_height = Silk_District.data(i);
    addMesh(scene,"Polygon",{[building_coords(:,2),building_coords(:,1)],[0 building_height]},[0 1 0],"UseLatLon",true);
end

position = 0;

for j = 1:4
    
    [no_of_buildings, dimension] = size(All_Buildings(j).features);
    
    for i = 1:no_of_buildings

        position = position + 1;
        
        if i ~= 218
            if All_Buildings(j).features(i).geometry.coordinates(:,:,1) >= -0.06221 & All_Buildings(j).features(i).geometry.coordinates(:,:,1) <= -0.05528 & All_Buildings(j).features(i).geometry.coordinates(:,:,2) >= 51.51603 & All_Buildings(j).features(i).geometry.coordinates(:,:,2) <= 51.52051 
            building_coords = transpose([All_Buildings(j).features(i).geometry.coordinates(:,:,2); All_Buildings(j).features(i).geometry.coordinates(:,:,1)]);
            building_height = All_Buildings(j).features(i).properties.height;
            end
        end

        addMesh(scene,"Polygon",{building_coords,[0 building_height]},[0 1 0],"UseLatLon",true,"ReferenceFrame","ENU");

    end
end

save('scene1.mat','scene')
title("Visualisation of imported OSM data");
show3D(scene)

traj1 = waypointTrajectory("Waypoints", coordvals1,"TimeOfArrival",t_hems1); 
uavPlat1 = uavPlatform("UAV1",scene,"Trajectory",traj1); 
updateMesh(uavPlat1,"quadrotor", {30}, [1 0 0],eul2tform([0 0 pi]));

actualpath_hems1 = lookupPose(traj1,0:0.2:60.63);
actualtime_hems1 = 0:0.2:60.63;
actualpath_hems1([265:304],3) = (-150:65/39:-85);

traj2 = waypointTrajectory("Waypoints", coordvals2([2:4],:),"TimeOfArrival",t_hems2([2:4]));
actualpath_hems2 = lookupPose(traj2,0:0.2:48.56);
actualtime_hems2 = 0:0.2:48.56;
actualpath_hems2([202:243],3) = 85:94/41:179;

ax = show3D(scene); 
hold on
% legend('');
title("Building Models with HEMS Trajectories",'FontSize',25);
xlabel("East(m)",'FontSize',20), ylabel("North(m)",'FontSize',20), zlabel("Up(m)",'FontSize',20);
set(gca,'FontSize',20);
a(1) = plot3(coordvals1(:,2),coordvals1(:,1),coordvals1(:,3)*-1,'LineWidth',3);  
a(2) = plot3(actualpath_hems1(:,2),actualpath_hems1(:,1),actualpath_hems1(:,3)*-1,'LineWidth',3); 
a(3) = plot3(coordvals2(:,2),coordvals2(:,1),coordvals2(:,3)*-1,'LineWidth',3); 
a(4) = plot3(actualpath_hems2(:,2),actualpath_hems2(:,1),actualpath_hems2(:,3),'LineWidth',3);
xlim([-300 300])
ylim([-300 300])
zlim([0 150])
legend(a(1:4),'HEMS 1 path from captured coordinates','HEMS 2 path from captured coordinates','HEMS 1 smoothed path','HEMS 2 smoothed path','FontSize',25)

setup(scene); 
% while advance(scene) 
%     % Update sensor readings 
%     updateSensors(scene); 
% 
%     % Visualize the scenario 
%     show3D(scene,"Parent",ax,"FastUpdate",true); 
%     drawnow limitrate 
% end 
hold off

