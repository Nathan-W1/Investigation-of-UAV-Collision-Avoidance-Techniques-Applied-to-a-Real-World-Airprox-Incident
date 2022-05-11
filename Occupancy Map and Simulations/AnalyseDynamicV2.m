clear all
load dataDynamic.mat

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

% openfig('map.fig');

% for i = 1:length(successesDynamic)
%     path = getfield(dataDynamic,char(successesDynamic(i)),'path');
% %         if all(path(:,3) > 0) && min(path(:,1)) > -250 && min(path(:,2)) > -210 && max(path(31:end,3)) > 80 
%             plot3(path(:,1), path(:,2), path(:,3),'LineWidth',2,'color','red'); hold on;
% %         end
% end

%% Create crash heatmap

load dataDynamic.mat
load closestCallDynamic.mat

names = fieldnames(dataDynamic);
j = 1;

for i = 1:length(names)
    crash(i) = getfield(dataDynamic,char(names(i)),'crash');
    rho(i) = getfield(dataDynamic,char(names(i)),'rho');
    sigma(i) = getfield(dataDynamic,char(names(i)),'sig');
    time(i) = getfield(dataDynamic,char(names(i)),'adjustedTime');
    pathlength(i) = length(getfield(dataDynamic,char(names(i)),'path'));
        if crash(i) == 0
            index(j) = i;
            j = j+1;
        end;
        
end

tab = table(rho',sigma',crash',time');
figure(1)
h = heatmap(tab,'Var1','Var2','ColorVariable','Var3','CellLabelColor','None');
set(gca,'FontSize',25);
XLabels = 1:100;
CustomXLabels = string(XLabels);
CustomXLabels(mod(XLabels,5) ~= 0) = " ";
h.XDisplayLabels = CustomXLabels;
h.YDisplayLabels = CustomXLabels;
xlabel("Rho0");
ylabel("Sigma0");
title("Heatmap Representing Crashes (Blue) and Successes (White) for Dynamic Case");

[rows cols] = find(closestCallDynamic' == maxk(closestCallDynamic,50));
Y = maxk(closestCallDynamic,50);
X = categorical(successesDynamic(rows));
X_CC = reordercats(X,successesDynamic(rows));
figure(2)
bar(X_CC,Y)
set(gca,'FontSize',20)
xlabel("Configuration")
ylabel("Closest Call (m)")
title("Largest 50 Closest Calls for Dynamic Case",'FontSize',25)

time = time(index)
[rows cols] = find(time' > 0.99999*mink(time,50) & time' < 1.00001*mink(time,50));
X_ToA = categorical(unique(successesDynamic(rows)));
Y = mink(time,length(X));

figure(3)
bar(X_ToA,Y)
set(gca,'FontSize',20)
xlabel("Configuration")
ylabel("Time of Arrival (s)")
title("Shortest 50 Times of Arrival for Dynamic Case",'FontSize',25)

pathlength = pathlength(index)
[rows cols] = find(pathlength' == mink(pathlength,50))
X_PL = categorical(unique(successesDynamic(rows)));
Y = mink(pathlength,length(X));

figure(4)
bar(X_PL,Y)
set(gca,'FontSize',20)
xlabel("Configuration")
ylabel("Path Length")
title("Shortest 50 Path Lengths for Dynamic Case",'FontSize',25)

figure(6)
plot(closestCallDynamic)
title("Distribution of Closest Calls for Dynamic Case",'FontSize',25)
xlabel("Test",'FontSize',20)
ylabel("Closest Call (m)",'FontSize',20)
set(gca,'FontSize',20)

figure(7)
plot(time)
title("Distribution of Times of Arrival for Dynamic Case",'FontSize',25)
xlabel("Test",'FontSize',20)
ylabel("Time of Arrival (s)",'FontSize',20)
set(gca,'FontSize',20)

figure(8)
plot(pathlength)
title("Distribution of Path Lengths for Dynamic Case",'FontSize',25)
xlabel("Test",'FontSize',20)
ylabel("Path Length",'FontSize',20)
set(gca,'FontSize',20)