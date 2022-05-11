%% X and Y tile calculator for retrieving .json file with building coordinates and height: https://data.osmbuildings.org/0.2/anonymous/tile/zoom/xtile/ytile.json

zoom = 16; % Zoom level
lat = 51.5212*(pi/180); % Lateral coordinate
lon = -0.0674; % Longitudinal coordinate

n = 2 ^ zoom;
xtile = n * ((lon + 180) / 360) % Calculate x tile number
ytile = n * 0.5 * (1 - (log(tan(lat) + (1/cos(lat)))/pi)) % Calculate y tile number
