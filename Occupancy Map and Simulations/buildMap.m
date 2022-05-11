function map = buildMap(obsCentre,obsR)
    
    no_obstacles = size(obsCentre);

    for k = 1:no_obstacles(1)
        
        map = drawSphere(obsCentre(k,:),obsR(k));
        
    end
    
end

function bar = drawSphere(pos, r)
[x,y,z] = sphere(60);
bar = surfc(r*x+pos(1), r*y+pos(2), r*z+pos(3));
hold on;
end