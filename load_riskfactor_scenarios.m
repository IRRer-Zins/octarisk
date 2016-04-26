%# Copyright (C) 2016 Stefan Schloegl <schinzilord@octarisk.com>
%#
%# This program is free software; you can redistribute it and/or modify it under
%# the terms of the GNU General Public License as published by the Free Software
%# Foundation; either version 3 of the License, or (at your option) any later
%# version.
%#
%# This program is distributed in the hope that it will be useful, but WITHOUT
%# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
%# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
%# details.

%# -*- texinfo -*-
%# @deftypefn {Function File} {@var{riskfactor_struct} @var{rf_failed_cell}} = load_riskfactor_scenarios(@var{riskfactor_struct}, @var{M_struct},@var{mc_timesteps},@var{mc_timestep_days})
%# Generate MC scenario shock values for risk factor curve objects. Store all MC scenario shock values in provided struct and return the final struct and a cell containing all failed risk factor ids.
%# @end deftypefn

function [riskfactor_struct rf_failed_cell ] = load_riskfactor_scenarios(riskfactor_struct,M_struct,mc_timesteps,mc_timestep_days)

rf_failed_cell = {};
number_riskfactors = 0;
tmp_id = 'Dummy';
% loop via all mc_timesteps and riskfactors and calculate risk factor MC scenario value
for kk = 1 : 1 : length( mc_timesteps )      % loop via all MC time steps
    try
        tmp_ts  = mc_timesteps{ kk };    % get timestep string
        ts      = mc_timestep_days(kk);  % get timestep days
        Y_tmp   = M_struct( kk ).matrix; % get matrix with correlated random numbers for all risk factors
        for ii = 1 : 1 : length( riskfactor_struct )    % loop via all risk factors: calculate risk factor deltas in each MC scenario
            rf_object = riskfactor_struct( ii ).object;
            tmp_model = rf_object.model;
            tmp_drift = rf_object.mean / 250;
            tmp_sigma = rf_object.std;
            tmp_id = rf_object.id;
            % correlated random variables vector from corr. random matrix M:
            Y       = Y_tmp(:,ii);
            % Case Dependency:
                % Geometric Brownian Motion Riskfactor Modeling
                    if ( strcmp(tmp_model,'GBM') )
                        tmp_delta 	    = Y + ((tmp_drift - 0.5 .* (tmp_sigma./ sqrt(256)).^2) .* ts);
                % Brownian Motion Riskfactor Modeling
                    elseif ( strcmp(tmp_model,'BM') )
                        tmp_delta 	    = Y + (tmp_drift * ts);
                % Black-Karasinski (log-normal mean reversion) Riskfactor Modeling
                    elseif ( strcmp(tmp_model,'BKM') )
                        % startlevel, sigma_p_a, mr_level, mr_rate
                        tmp_start       = rf_object.value_base;
                        tmp_mr_level    = rf_object.mr_level;
                        tmp_mr_rate     = rf_object.mr_rate;    
                        tmp_delta       = Y + (tmp_mr_rate * ( tmp_mr_level - tmp_start ) * ts);
                % Ornstein-Uhlenbeck process 
                    elseif ( strcmp(tmp_model,'OU') )    
                        % startlevel, sigma_p_a, mr_level, mr_rate
                        tmp_start       = rf_object.value_base;
                        tmp_mr_level    = rf_object.mr_level;
                        tmp_mr_rate     = rf_object.mr_rate;     
                        tmp_delta       = Y + (tmp_mr_rate * ( tmp_mr_level - tmp_start ) * ts);
                % Square-root diffusion process
                    elseif ( strcmp(tmp_model,'SRD') )    
                        % startlevel, sigma_p_a, mr_level, mr_rate
                        tmp_start       = rf_object.value_base;
                        tmp_mr_level    = rf_object.mr_level;
                        tmp_mr_rate     = rf_object.mr_rate;     
                        tmp_delta       = sqrt(tmp_start) .* Y + (tmp_mr_rate * ( tmp_mr_level - tmp_start ) * ts);
                    end     
            % store increment for actual riskfactor and scenario number
            rf_object = rf_object.set('scenario_mc',tmp_delta,'timestep_mc',tmp_ts);
            % store risk factor object back into struct:
            riskfactor_struct( ii ).object = rf_object;    
            number_riskfactors = number_riskfactors + 1;
        end  % close loop via all risk factors  
    catch
        fprintf('WARNING: There has been an error for curve: >>%s<< in MC timestep: >>%s<<. Aborting: >>%s<<\n',tmp_id,tmp_ts,lasterr);
        rf_failed_cell{ length(rf_failed_cell) + 1 } =  tmp_id;
    end
end      % close loop via all mc_timesteps

        
rf_failed_cell = unique(rf_failed_cell); 
% returning statistics
fprintf('SUCCESS: generated MC scenario values for >>%d<< risk factors in %d MC timesets.\n',number_riskfactors/kk,kk);
if (length(rf_failed_cell) > 0 )
    fprintf('WARNING: >>%d<< risk factors failed during MC scenario generation: \n',length(rf_failed_cell));
    rf_failed_cell
end 

end