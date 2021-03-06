% Index Superclass, for documentation see dummy function doc_Index.m TODO
classdef Index
   % file: @Index/Index.m
   properties
      name = '';
      id = '';
      description = '';
      currency = 'EUR';
      value_base = 1;
      type = ''; 
   end
   
    properties (SetAccess = protected )
      scenario_stress = [];
      scenario_mc = [];
      shift_type = [];
      timestep_mc = {};
    end
 
   % Class methods
   methods
        
      function a = Index(tmp_name)
         % Index Constructor method
        if nargin < 1
            tmp_name            = 'Test Index';
            tmp_id              = 'EUR-INDEX-TEST';
        else 
            tmp_id = tmp_name;
        end 
        tmp_currency    = 'EUR';
        tmp_description = 'Test index for multi purpose use';
        tmp_type        = 'Equity Index';
        tmp_value_base  = 10321.45;

        a.name          = tmp_name;
        a.id            = tmp_id;
        a.description   = tmp_description;
        a.type          = upper(tmp_type);
        a.currency      = tmp_currency;
        a.value_base    = tmp_value_base;           
      end % Index
      
      function disp(a)
         % Display a Index object
         % Get length of Value vector:
         scenario_stress_rows = min(rows(a.scenario_stress),5);
         scenario_mc_rows = min(rows(a.scenario_mc),5);
         scenario_mc_cols = min(length(a.scenario_mc),2);
         fprintf('name: %s\nid: %s\ndescription: %s\ntype: %s \ncurrency: %s\n', ... 
            a.name,a.id,a.description,a.type,a.currency);
         fprintf('value_base: %8.5f\n',a.value_base);
         if ( length(a.scenario_stress) > 0 ) 
            fprintf('Scenario stress: %8.5f \n',a.scenario_stress(1:scenario_stress_rows));
            fprintf('\n');
         end
         % looping via first 5 MC scenario values
         for ( ii = 1 : 1 : scenario_mc_cols)
            if ( length(a.timestep_mc) >= ii )
                fprintf('MC timestep: %s\n',a.timestep_mc{ii});
                fprintf('Scenariovalue: %8.5f \n',a.scenario_mc(1:scenario_mc_rows,ii));
            end
            
            fprintf('\n');
         end
      end % disp
           
      function obj = set.type(obj,type)
         if ~(sum(strcmpi(upper(type),{'EQUITY INDEX','BOND INDEX','VOLATILITY INDEX','COMMODITY INDEX','REAL ESTATE INDEX','EXCHANGE RATE','CPI'}))>0  )
            error('Risk factor type must be either EQUITY INDEX, BOND INDEX, VOLATILITY INDEX, COMMODITY INDEX, REAL ESTATE INDEX,EXCHANGE RATE,CPI')
         end
         obj.type = type;
      end % Set.type
      
    end
    
    methods (Static = true)
    
      function basis = get_basis(dcc_string)
            % provide static method for converting dcc string into basis value
            basis = get_basis(dcc_string);
      end %get_basis
      
      function retval = get_doc(format,path)
        if nargin < 1
            format = 'plain text';
        end
        if nargin < 2
            printflag = 0;
        elseif nargin == 2
            if (ischar(path) && length(path) > 1)
                printflag = 1;
            else
                error('Insufficient path: %s \n',path);
            end
        end
        % printing documentation for Class Index (ousourced to dummy function to use documentation behaviour)
        scripts = ['doc_index'];
        c = cellstr(scripts);
        for ii = 1:length(c)
            [retval status] = __makeinfo__(get_help_text(c{ii}),format);
        end
        if ( status == 0 )
            if ( printflag == 1) % print to file
                if (strcmp(format,'html'))
                    ending = '.html';
                    %replace html title
                    repstring = strcat('<title>', c{ii} ,'</title>');
                    retval = strrep( retval, '<title>Untitled</title>', repstring);
                elseif (strcmp(format,'texinfo'))
                    ending = '.texi';
                else
                    ending = '.txt';
                end
                filename = strcat(path,c{ii},ending);
                fid = fopen (filename, 'w');
                fprintf(fid, retval);
                fprintf(fid, '\n');
                fclose (fid); 
            else    
                fprintf('Documentation for Class %s: \n',c{ii}(4:end));
                fprintf(retval);
                fprintf('\n');
            end
                     
        else
            disp('There was a problem')
        end
        retval = status;
      end
            
   end
   
end % classdef
