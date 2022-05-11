clear all

load dataDynamic.mat
% dataDynamic = struct;
[row length] = size(struct2table(dataDynamic));
progress = length/200;

for rho = 53:100
    
    rho = rho
    rhoVal = strcat('Rho',num2str(rho));
    
    for sig = 1:100
       
        sig = sig
        sigmaVal = strcat('Sig',num2str(sig));
        rhoSigmaVal = strcat(rhoVal,sigmaVal);
        dataDynamic.(rhoSigmaVal) = planIFDSdynamic(rho,sig);
        
    end
    
    save('dataDynamic.mat','dataDynamic');
    
end

save('dataDynamic.mat','dataDynamic')