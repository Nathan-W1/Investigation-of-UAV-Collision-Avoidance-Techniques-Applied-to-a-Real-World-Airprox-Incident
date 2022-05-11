lear all
load data.mat

names = fieldnames(data);
j = 1;

for i = 1:length(names)
    crash(i) = getfield(data,char(names(i)),'crash');
        
        if crash(i) == 0
            index(j) = i;
            j = j+1;
        end;
        
end

successes = names(index);

openfig('map.fig');

figure(1)
% for i = 1:length(successes)
%     path = getfield(data,char(successes(i)),'path');
%         
%     plot3(path(:,1), path(:,2), path(:,3),'LineWidth',2,'color','red'); hold on;
%        
% end

hold off
%% Create crash heatmap

load data.mat
load closestCallDynamic.mat

names = fieldnames(data);
j = 1;

for i = 1:length(names)
    crash(i) = getfield(data,char(names(i)),'crash');
    rho(i) = getfield(data,char(names(i)),'rho');
    sigma(i) = getfield(data,char(names(i)),'sig');
    time(i) = getfield(data,char(names(i)),'adjustedTime');
    pathlength(i) = length(getfield(data,char(names(i)),'path'));
    closestCall(i) = getfield(data,char(names(i)),'closestCall');
        if crash(i) == 0
            index(j) = i;
            j = j+1;
        end;
        
end

tab = table(rho',sigma',crash',time');
figure(2)
h = heatmap(tab,'Var1','Var2','ColorVariable','Var3','CellLabelColor','None');
set(gca,'FontSize',25);
XLabels = 1:100;
CustomXLabels = string(XLabels);
CustomXLabels(mod(XLabels,5) ~= 0) = " ";
h.XDisplayLabels = CustomXLabels;
h.YDisplayLabels = CustomXLabels;
xlabel("Rho0");
ylabel("Sigma0");
title("Heatmap Representing Crashes (Blue) and Successes (White) for Static Case");

[rows cols] = find(closestCall(index)' == mink(closestCall(index),50));
Y = mink(closestCall(index),50);
X = categorical(successes(rows));
X_CC = reordercats(X,successes(rows));
figure(3)
bar(X_CC,Y)
set(gca,'FontSize',20)
xlabel("Configuration")
ylabel("Closest Call (m)")
title("Largest 50 Closest Calls for Static Case",'FontSize',25)

time = time(index)
[rows cols] = find(time == mink(time,50)');
X_ToA = categorical(unique(successes(rows)));
Y = mink(time,length(X_ToA));

figure(4)
bar(X_ToA,Y)
set(gca,'FontSize',20)
xlabel("Configuration")
ylabel("Time of Arrival (s)")
title("Shortest 50 Times of Arrival for Static Case",'FontSize',25)

pathlength = pathlength(index)
[rows cols] = find(pathlength == mink(pathlength,50)')
X_PL = categorical(unique(successes(rows)));
Y = mink(pathlength,length(X));

figure(5)
bar(X_PL,Y)
set(gca,'FontSize',20)
xlabel("Configuration")
ylabel("Path Length")
title("Shortest 50 Path Lengths for Static Case",'FontSize',25)

figure(6)
plot(closestCall(index))
title("Distribution of Closest Calls for Static Case",'FontSize',25)
xlabel("Test",'FontSize',20)
ylabel("Closest Call (m)",'FontSize',20)
set(gca,'FontSize',20)

figure(7)
plot(time)
title("Distribution of Times of Arrival for Static Case",'FontSize',25)
xlabel("Test",'FontSize',20)
ylabel("Time of Arrival (s)",'FontSize',20)
set(gca,'FontSize',20)

figure(8)
plot(pathlength)
title("Distribution of Path Lengths for Static Case",'FontSize',25)
xlabel("Test",'FontSize',20)
ylabel("Path Length",'FontSize',20)
set(gca,'FontSize',20)