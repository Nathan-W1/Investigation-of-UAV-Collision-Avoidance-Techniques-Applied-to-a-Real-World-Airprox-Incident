load 'HEMS1 coords.txt'
load 'HEMS2 coords.txt'
coords1 = deg2km(HEMS1_coords);
coords2 = deg2km(HEMS2_coords);

latloncenter = [51.51795 -0.05856 1000];
latloncenterkm = deg2km(latloncenter);

coordvals1 = (coords1(:,:) - latloncenterkm([1:2]))*1000;
coordvals2 = (coords2(:,:) - latloncenterkm([1:2]))*1000;

%% HEMS1 phase 1: decelaration
a = -4.64;
u = 56.6;
v = 10.4;
s = 333.4;

% For the first 3 waypoints
d0 = coordvals1(1,:);
d_12 = sqrt((coordvals1(2,1)-d0(1)).^2 + (coordvals1(2,2)-d0(2)).^2);
t1 = 0;
t2 = roots([0.5*a u -d_12])
d0 = coordvals1(2,:);
d_23 = sqrt((coordvals1(3,1)-d0(1)).^2 + (coordvals1(3,2)-d0(2)).^2);
t3 = roots([0.5*a u -d_23(1)]) + t2

% For the last 7 waypoints
for i = 3:9
    d0 = coordvals1(i,:);
    d(i-2) = sqrt((coordvals1(i+1,1)-d0(1)).^2 + (coordvals1(i+1,2)-d0(2)).^2);
    if i > 3
        d_cum(i-2) = d(i-2) + d_cum(i-3);
    elseif i == 3
        d_cum(i-2) = d(i-2);
    end
end

t = d_cum/v;
t_hems1 = [t1 min(t2) min(t3) t];


%% Deceleration to stop

u = 10.4;
a = -7.72;
v = 0;

t = (v-u)/
%% HEMS2 times of arrival

a = 11.84;
u = 0;

d2(1) = 0;
d2(2) = sqrt((coordvals2(2,1)-coordvals2(1,1)).^2 + (coordvals2(2,2)-coordvals2(1,2)).^2);
d2(3) = sqrt((coordvals2(3,1)-coordvals2(2,1)).^2 + (coordvals2(3,2)-coordvals2(2,2)).^2);

t1 = 0;
t2 = roots([0.5*a u -d2(2)]);
t3 = roots([0.5*a u -d2(3)]);

t_hems2 = [t1 min(t2) min(t3)]*-1;
t_hems2 = t_hems2 + 40



