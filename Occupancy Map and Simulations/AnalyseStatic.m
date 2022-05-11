clear all
load dataV1.mat

names = fieldnames(data);
j = 1;

for i = 1:length(names)
    crash(i) = getfield(data,char(names(i)),'crash');
        
        if crash(i) == 0
            index(j) = i;
            j = j+1;
        end;
        
end

successesDynamic = names(index);

openfig('map.fig');

for i = 1:length(successesDynamic)
    path = getfield(data,char(successesDynamic(i)),'path');
        if all(path(:,3) > 0) && min(path(:,1)) > -250 && min(path(:,2)) > -250 && max(path(31:end,3)) > 80 && max(path(:,2)) < 250 && max(path(:,1)) < 250
            plot3(path(:,1), path(:,2), path(:,3),'LineWidth',2,'color','red'); hold on;
        end
end