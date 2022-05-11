clear all
load data.mat

[row length] = size(struct2table(data));
progress = length/200;

for rho = 83:100
    
    rho = rho
    rhoVal = strcat('Rho',num2str(rho));
    
    for sig = 1:100
        
        sig = sig
        sigmaVal = strcat('Sig',num2str(sig));
        rhoSigmaVal = strcat(rhoVal,sigmaVal);
        data.(rhoSigmaVal) = planIFDSstatic(rho,sig);
        
    end
    
    save('data.mat','data');
    
end

save('data.mat','data')