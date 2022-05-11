function pathPlan = planIFDSdynamic(rho0,sig0);

pathPlan = struct
try delete(route), catch, end
V0 = 10.4; 
threshold = 10;
stepSize = 0.2;
rho0 = rho0;
sig0 = sig0;
load ObsFeatures.mat
load HEMS1_actual_path.mat
load HEMS1_actual_times.mat
load HEMS2_actual_times.mat
load HEMS2_actual_path.mat
% demo1: Static Spherical Obstacle
start = [214 242 20];
goal = [-50 -154 20];

features0 = features;

% Plot environment
% scatter3(start(1),start(2),start(3),60,"cyan",'filled','o','MarkerEdgeColor','k');hold on
% scatter3(goal(1),goal(2),goal(3),60,"magenta",'filled',"o",'MarkerEdgeColor','k')
% text(start(1),start(2),start(3),'Start');
% text(goal(1),goal(2),goal(3),'Goal');
% xlabel('x(m)'); ylabel('y(m)'); zlabel('z(m)');
% title('UAV Path Planning'); axis equal;

% Start
pos = start;
path = pos;
no_obstacles = size(features);
obs = features([1:no_obstacles(1)],:);
obsCentre([1:no_obstacles(1)],:) = obs(:,[1:3]);

for k = 1:no_obstacles(1)
            
    obsR(k,1) = min(obs(k,[4:6]));
            
end

% openfig('map.fig')

realTime = 0;
time = 0;
crash = 0;
closestCall = inf;
no_obstacles(1) = no_obstacles(1)+2
while distanceCost(pos, goal) > threshold
       
        if time == 0
            path_position = 1;
        else
            path_position = (time/0.2)+1;
        end
        
        path_position = uint16(path_position);        
        HEMS_R = 50;
        
        if time < 60.8
        HEMS1_features = [actualpath_hems1(path_position,:), HEMS_R, HEMS_R, HEMS_R, 1, 1, 1,];
        end
        
        if time < 48.6
        HEMS2_features = [actualpath_hems2(path_position,:), HEMS_R, HEMS_R, HEMS_R, 1, 1, 1,];
        end
                
%         try delete(B3), catch, end        
%         if time < 60.8
%             try delete(B1), catch, end
%             B1 = drawSphere(actualpath_hems1(path_position,:),50);
%         end
%         if time < 48.6
%             try delete(B2), catch, end
%             B2 = drawSphere(actualpath_hems2(path_position,:),50);
%         end
%         
%         B3 = scatter3(pos(1),pos(2),pos(3),80,'filled',"^",'MarkerFaceColor','g'...
%                   ,'MarkerEdgeColor','k');
%         
%         drawnow;
        
        features = [features0; HEMS1_features; HEMS2_features];
        obs = features(:,:);
        obsR([no_obstacles(1)-1:no_obstacles(1)],1) = HEMS_R;
        if time < 60.8
        obsCentre(no_obstacles(1)-1,:) = [actualpath_hems1(path_position,:)];
        end
        if time < 48.6
        obsCentre(no_obstacles(1),:) = [actualpath_hems2(path_position,:)];
        end
                
        x = pos(1);
        y = pos(2);
        z = pos(3);

        x0 = obs(:,1);
        y0 = obs(:,2);
        z0 = obs(:,3);
        a = obs(:,4);
        b = obs(:,5);
        c = obs(:,6);
        d = obs(:,7);
        e = obs(:,8);
        f = obs(:,9);

        F(:,1) = ((x-x0)./a).^(2.*d) + ((y-y0)./b).^(2.*e) + ((z-z0)./c).^(2.*f);

        for k = 1:no_obstacles(1)
            w_temp(k,:) = (F-1)./((F(k,1)-1) + (F-1));
        end

        
        w_temp = w_temp + 0.5*eye(no_obstacles(1));
        w_temp(w_temp > 1) = 1;
        w = prod(w_temp')';

        for k = 1:no_obstacles(1)
            w_bar(k,1) = w(k,1)/sum(w([1:no_obstacles(1)-1],1));
        end
        
        u = initField(pos, V0, goal);
        n(:,:) = partialDerivative(obs, pos, no_obstacles(1));
        tempD(:,:) = distanceCost(pos, obsCentre) - obsR; % Distance to obstacle surface
        DistToCentre = distanceCost(pos, obsCentre);
        
        for k = 1:no_obstacles
            if DistToCentre(k) < obsR(k)
                crash = 1;
            end
        end
        
        if crash == 1;
            break
        end
        
        rho(:,1) = rho0 * exp(1-1/(distanceCost(pos, goal).*tempD)); 
        sig(:,1) = sig0 * exp(1-1/(distanceCost(pos, goal).*tempD)); 
        t = calculateT(obs,pos,no_obstacles(1));

        
        for k = 0:no_obstacles-1
            
            s = (k*3)+1';
            e = s + 2';
            
            tau(k+1,1) = (u'*t(:,k+1)*n(:,k+1)'*u)/threshold;
            Rep([s:e],:) = (n(:,k+1) * n(:,k+1)') ./ ((F(k+1,1)^(1/rho(k+1,1))) .* ((n(:,k+1)'*n(:,k+1))));
            Tang([s:e],:) = (tau(k+1).*t(:,k+1).*n(:,k+1)')./((F(k+1,1).^(1/sig(k+1,1))).*norm(t(:,k+1)).*norm(n(:,k+1)));
            M([s:e],:) = eye(3) - Rep([s:e],:) + Tang([s:e],:);
            wP([s:e],:) = M([s:e],:)*w_bar(k+1,1);
            
        end
        
        P = zeros(3,3);
        
        for k = 0:no_obstacles-1
            
            
            s = (k*3)+1';
            e = s + 2';
            
            P = wP([s:e],:) + P;
            
        end
             
        ubar = (P * u)';
        speed = sqrt(ubar(1)^2 + ubar(2)^2 + ubar(3)^2);
        
        if speed > V0
            ubar = limitVelocity(ubar,V0);
            isVelocityLimited = 1;
        end
            
        
        nextPos = pos + ubar * stepSize;
        path = [path;nextPos];
%         time_step = calculateTime(pos,nextPos,V0);
        time = time + stepSize;
%         realTime = realTime + time_step;
%         time = 0.2*round(time/0.2);
%          b2 = plot3([pos(1),nextPos(1)],[pos(2),nextPos(2)],[pos(3),nextPos(3)],'LineWidth',2,'color','r');
        pos = nextPos;
        
        if length(path) > 10000
            break
        end
     
end
    

%path = [path;goal];
%  route = plot3(path(:,1), path(:,2), path(:,3),'LineWidth',2,'color','red'); hold on;

pathPlan.rho = rho0;
pathPlan.sig = sig0;
pathPlan.path = path;
pathPlan.closestCall = closestCall;
pathPlan.timeOfArrival = realTime;
pathPlan.adjustedTime = time;
pathPlan.crash = crash;

end

function h=distanceCost(a,b)
h = sqrt(sum((a-b).^2, 2));
end
% Initial flow field solver
function u = initField(pos, C, goal)
u = -[(pos(1)-goal(1)), (pos(2)-goal(2)), (pos(3)-goal(3))]' * C / distanceCost(pos, goal);
end
% Ball drawing function
function bar = drawSphere(pos, r)
[x,y,z] = sphere(5);
bar = surfc(r*x+pos(1), r*y+pos(2), r*z+pos(3));
hold on;
end

%Partial derivative of ball function
function pd = partialDerivative(obs, pos, size)
pd = zeros(size,3);
dFdx = zeros(size,1);
dFdy = zeros(size,1);
dFdz = zeros(size,1);

x = pos(1);
y = pos(2);
z = pos(3);
x0 = obs(:,1);
y0 = obs(:,2);
z0 = obs(:,3);
a = obs(:,4);
b = obs(:,5);
c = obs(:,6);
d = obs(:,7);
e = obs(:,8);
f = obs(:,9);
 
dFdx = 2.*d.*(1./a.^2.*d).*(x-x0).^(2.*d-1);
dFdy = 2.*e.*(1./b.^2.*e).*(y-y0).^(2.*e-1);
dFdz = 2.*f.*(1./c.^2.*f).*(z-z0).^(2.*f-1);

pd = [dFdx dFdy dFdz]';
end
% Ball obstacle T calculation
function T = calculateT(obs,pos,size)
T = zeros(size,3);
dFdx = zeros(size,1);
dFdy = zeros(size,1);

x = pos(1);
y = pos(2);
z = pos(3);
x0 = obs(:,1);
y0 = obs(:,2);
z0 = obs(:,3);
a = obs(:,4);
b = obs(:,5);
c = obs(:,6);
d = obs(:,7);
e = obs(:,8);
f = obs(:,9);

dFdx = 2.*d.*(1./a.^2.*d).*(x-x0).^(2.*d-1);
dFdy = 2.*e.*(1./b.^2.*e).*(y-y0).^(2.*e-1);

T = [dFdy -dFdx zeros(size,1)]';
end

function L = calVecLen(vec)
L = sqrt(sum(vec.^2));
end

function time_step = calculateTime(prevPos,pos,v0)
x0 = prevPos(1);
y0 = prevPos(2);
z0 = prevPos(3);
x = pos(1);
y = pos(2);
z = pos(3);

dist = sqrt((x-x0)^2 + (y-y0)^2 + (z-z0)^2);
time_step = dist/v0;
end

function ubar_new = limitVelocity(ubar,v0);
vx = ubar(1);
vy = ubar(2);
vz = ubar(3);
speed = sqrt(vx^2 + vy^2 + vz^2);
xy = (vx^2)/(vy^2);
zy = (vz^2)/(vy^2);

vy2 = ((vx^2 + vy^2 + vz^2) * v0^2)/(speed^2*(xy + 1 + zy));
vy2 = sqrt(vy2);

vx2 = (vx/vy) * vy2;
vz2 = (vz/vy) * vy2;
ubar_new = [vx2 vy2 vz2];
end


    
