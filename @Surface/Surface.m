classdef Surface
   % file: @Surface/Surface.m
    properties
      name = '';
      id = '';
      description = '';
      type = ''; 
      moneyness_type = 'K/S'; % in list {'K/S','K-S'}
      compounding_type = 'cont';
      compounding_freq = 'annual';               
      day_count_convention = 'act/365';
      method_interpolation = 'linear';    % 3D: [linear,nearest]
      shock_struct = struct();      % structure containing risk factor shocks
      riskfactors = {};             % cell containing all risk factors
    end
   
    properties (SetAccess = protected )
      axis_x = [];
      axis_y = [];
      axis_z = [];
      values_base = [];
      axis_x_name = '';
      axis_y_name = '';
      axis_z_name = ''; 
      basis = 3;      
    end
 
   % Class methods
   methods
      function a = Surface(tmp_name)
       % Surface Constructor method
        if nargin < 1
            name        = 'Index Test Vola Surface';
            tmp_id      = 'VOLA_INDEX_EUR';
        else
            name        = tmp_name;
            tmp_id      = tmp_name;
        end
        tmp_description = 'Test Dummy Surface';
        tmp_type        = 'INDEX';
        a.name          = name;
        a.id            = tmp_id;
        a.description   = tmp_description;
        a.type          = upper(tmp_type);  
      end % Surface
      
      function disp(a)
         % Display a Surface object
         % Get length of Value vector:
         fprintf('name: %s\nid: %s\ndescription: %s\ntype: %s\n', ... 
            a.name,a.id,a.description,a.type);
         fprintf('moneyness_type: %s\n',a.moneyness_type);
         fprintf('method_interpolation: %s\n',a.method_interpolation);
         fprintf('riskfactors: %s\n',any2str(a.riskfactors));
         % looping via all x axis values if defined
         if ( length(a.axis_x) > 0 )
            fprintf('Axis x %s : Values :\n[ ',a.axis_x_name);
            for (ii = 1 : 1 : length(a.axis_x))
                fprintf('%d,',a.axis_x(ii));
            end
            fprintf(' ]\n');
         end
         % looping via all y axis values if defined
         if ( length(a.axis_y) > 0 )
            fprintf('Axis y %s : Values :\n[ ',a.axis_y_name);
            for (ii = 1 : 1 : length(a.axis_y))
                fprintf('%d,',a.axis_y(ii));
            end
            fprintf(' ]\n');
         end
         % looping via all z axis values if defined
         if ( length(a.axis_z) > 0 )
            fprintf('Axis z %s : Values :\n[ ',a.axis_z_name);
            for (ii = 1 : 1 : length(a.axis_z))
                fprintf('%d,',a.axis_z(ii));
            end
            fprintf(' ]\n');
         end
         
         % looping via all values if defined
         if ( length(a.values_base) > 0 )
            fprintf('Surface base values:\n[ ');
            [aa bb cc ] = size(a.values_base);
            for ( kk = 1 : 1 : cc)
                if ( length(a.axis_z) == cc );fprintf('%s : %d\n',a.axis_z_name, a.axis_z(kk));end;
                for ( jj = 1 : 1 : aa)
                    fprintf('%f,',a.values_base(jj,:,kk));
                    fprintf('\n');
                end
            end
            fprintf(' ]\n');
         end   
      end % disp
      
      function obj = set.type(obj,type)
         if ~(strcmpi(type,'Index') || strcmpi(type,'IR')  ...
                || strcmpi(type,'Dummy')  || strcmpi(type,'Prepayment') ...
                || strcmpi(type,'Stochastic')                 )
            error('Type must be either Index, IR, Stochastic, Prepayment or Dummy Surface')
         end
         obj.type = type;
      end % Set.type
      
      function obj = set.day_count_convention(obj,day_count_convention)
        obj.day_count_convention = day_count_convention;
        % Call superclass method to set basis
        obj.basis = Instrument.get_basis(obj.day_count_convention);
      end % set.day_count_convention
      
      function obj = set.moneyness_type(obj,moneyness_type)
        moneyness_type = upper(moneyness_type);
        moneyness_type = strrep (moneyness_type,' ', '');
        if ~(sum(strcmpi(moneyness_type,{'K/S','K-S'}))>0  )
            fprintf('Curve:set: for curve >>%s<<: moneyness_type >>%s<< must be K/S or K-S. Setting to >>K/S<<\n',obj.id,moneyness_type);
            moneyness_type = 'K/S';
        end
         obj.moneyness_type = moneyness_type;
      end % set.moneyness_type
      
      function obj = set.compounding_freq(obj,compounding_freq)
        compounding_freq = lower(compounding_freq);
        if ~(sum(strcmpi(compounding_freq,{'day','daily','week','weekly','month','monthly','quarter','quarterly','semi-annual','annual'}))>0  )
            fprintf('Curve:set: for curve >>%s<<: compounding_freq >>%s<< must be either day,daily,week,weekly,month,monthly,quarter,quarterly,semi-annual,annual. Setting to >>annual<<\n',obj.id,compounding_freq);
            compounding_freq = 'annual';
        end
         obj.compounding_freq = compounding_freq;
      end % set.compounding_freq
      
      
      function obj = set.compounding_type(obj,compounding_type)
        compounding_type = lower(compounding_type);
        if ~(sum(strcmpi(compounding_type,{'simple','continuous','discrete'}))>0  )
            fprintf('Curve:set: for curve >>%s<<: Compounding type >>%s<< must be either >>simple<<, >>continuous<<, or >>discrete<<. Setting to >>continuous<<\n',obj.id,compounding_type);
            compounding_type = 'continuous';
        end
         obj.compounding_type = compounding_type;
      end % set.compounding_type
      
      function obj = set.method_interpolation(obj,method_interpolation)
         if ~(sum(strcmpi(method_interpolation,{'linear','nearest'}))>0  )
            error('Interpolation method >>%s<< must be linear or nearest.',any2str(method_interpolation))
         end
         obj.method_interpolation = method_interpolation;
      end % Set.method_interpolation
      
   end
   
end % classdef
