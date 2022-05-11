clear all
load dataDynamicV1.mat

names = fieldnames(dataDynamic);
j = 1;

for i = 1:length(names)
    crash(i) = getfield(dataDynamic,char(names(i)),'crash');
        
        if crash(i) == 0
            index(j) = i;
            j = j+1;
        end;
        
end

successesDynamic = names(index);

openfig('map.fig');

for i = 1:length(successesDynamic)
    path = getfield(dataDynamic,char(successesDynamic(i)),'path');
        if length(path) < 100 && all(path(:,3) > 0) && min(path(:,1)) > -250 && min(path(:,2)) > -210  
            plot3(path(:,1), path(:,2), path(:,3),'LineWidth',2,'color','red'); hold on;
            
        end
end