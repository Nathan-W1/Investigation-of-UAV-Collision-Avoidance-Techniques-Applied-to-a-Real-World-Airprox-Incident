clear all

load scene1.mat

res = 0.5; % Set resolution to 0.5 cells/m, or 2m
map3D = occupancyMap3D(res); % Create occupancy map with specified resolution

N = 1/res; % Parameter for defining spacing

pose = [ 0 0 0 1 0 0 0]; % Define pose
maxRange = 2000; % Define max range
xy_nf = 1;
xy_f = 2;
z_nf = 3;
z_f = 4;

[dimension, no_meshes] = size(scene.Meshes); % Determine number of meshes
features = zeros(no_meshes,9);

for i = 1:no_meshes
       
    [no_faces, dimension] = size(scene.Meshes{1,i}.Faces); % Determine number of faces for each mesh
    
    for j = 1:no_faces
    
    vertex_position = scene.Meshes{1,i}.Faces(j,:); % Get corresponding vertex positions
    face_vertices = scene.Meshes{1,i}.Vertices(vertex_position,:); % Get vertex coordinates
    orientation = xy_nf; % Default to the face being in the xy plane, not flipped
    
    [max_pos col] = find(face_vertices == max(face_vertices(:,3))); % Return the position of max z values
    max_no = size(max_pos); % Return how many z values are maximums
    
    if max_no(1) == 2 % If there are two max values
        
        orientation = xy_f; % Face is in xy plane and flipped
               
    elseif face_vertices(1,3) == face_vertices(2,3) && face_vertices(1,3) == face_vertices(3,3) % Check if all z values are the same
        
        orientation = z_nf; % Face is in z plane, default to not flipped
    
    end
    
    xvector = min(face_vertices(:,1)):N:max(face_vertices(:,1)); % Create vectors containing all numbers between vertices
    yvector = min(face_vertices(:,2)):N:max(face_vertices(:,2));
    zvector = min(face_vertices(:,3)):N:max(face_vertices(:,3));
    
    xv = face_vertices(:,1);
    yv = face_vertices(:,2);
    [inPoints] = polygrid(xv,yv,res);
    no_points = size(inPoints);
    inPoints = [inPoints ones(no_points(1),1)*face_vertices(1,3)];
    setOccupancy(map3D,inPoints,1);
       
    sizex = size(xvector);
    sizey = size(yvector);
    sizez = size(zvector);
    sizes = [sizex sizey sizez];
    max_size = max(sizes);
    xvector2 = imresize(xvector,[1 max_size],'nearest');
    yvector2 = imresize(yvector,[1 max_size],'nearest');
    zvector2 = imresize(zvector,[1 max_size],'nearest');
    edges = [xvector2; yvector2; zvector2]';
        
    setOccupancy(map3D,edges,1);
    
    if orientation == 1 || orientation ==2
        
        fillHeight(map3D,edges,orientation); 
        
    end
   
    
    
    
    end
    
    mesh = scene.Meshes{1,i}.Vertices;
    
    x0 = (max(mesh(:,1))+min(mesh(:,1)))/2;
    y0 = (max(mesh(:,2))+min(mesh(:,2)))/2;
    z0 = (max(mesh(:,3))+min(mesh(:,3)))/2;
    a = max(mesh(:,1))-min(mesh(:,1));
    b = max(mesh(:,2))-min(mesh(:,2));
    c = max(mesh(:,3))-min(mesh(:,3));
    d = 5;
    e = 5;
    f = 5;
    
    features(i,:) = [x0 y0 z0 a b c d e f];
    
end

show(map3D);


%%


