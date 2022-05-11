function fillxy(map3D,res,point,last_point)

dif = point - last_point;
no_points  = [ceil(dif(1,1)*res*2),floor(dif(1,2)*res*2),0];
increment = dif./abs(no_points);
        
if abs(dif(1)) > 0
    for w = 1:abs(no_points(1))
        addpoint = [last_point(1)+w*increment(1), last_point(2), last_point(3)];
        setOccupancy(map3D,addpoint,1);
        fillHeight(map3D,addpoint);
    end
end

if abs(dif(2)) > 0
    for n = 1:abs(no_points(2))
        addpoint = [last_point(1), last_point(2)+n*increment(2), last_point(3)];
        setOccupancy(map3D,addpoint,1);
        fillHeight(map3D,addpoint);
    end
end