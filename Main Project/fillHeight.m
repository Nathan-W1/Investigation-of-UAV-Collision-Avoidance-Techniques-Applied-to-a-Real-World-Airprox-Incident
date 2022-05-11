unction fillHeight(map,edge,orientation)

no_points = size(edge);    

for k = 1:no_points(1)
        
    if orientation == 2
        
        zAxisPoints = edge(k,3):2:max(edge(:,3));
        zAxisPoints = flip(zAxisPoints);
    
    else
        
        zAxisPoints = 0:2:edge(k,3);
    
    end
        
    
    
    size_z = size(zAxisPoints);
    
    if size_z(2) > 0
    xyPoints = imresize(edge(k,[1 2]),[size_z(2) 2]);                
    points = [xyPoints zAxisPoints'];           
    setOccupancy(map,points,1);
    end
    
end
   
   
end
