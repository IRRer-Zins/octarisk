%# -*- texinfo -*-
%# @deftypefn  {Function File} {} Instrument ()
%# @deftypefnx {Function File} {} Instrument (@var{a})
%# Instrument Superclass 
%#
%# @*
%# Inherited superclass properties:
%# @itemize @bullet
%# @item name: Name of object
%# @item id: Id of object
%# @item description: Description of object
%# @item value_spot: Actual spot value of object
%# @item currency
%# @item asset_class 
%# @item type: Type of Instrument class (Bond,Forward,...) 
%# @item value_stress: Vector with values under stress scenarios
%# @item value_mc: Matrix with values under MC scenarios (values per timestep per column)
%# @item timestep_mc: MC timestep per column (cell string)
%# @end itemize
%# @*
%#
%# @seealso{Bond, Forward, Option, Swaption, Debt, Sensitivity, Synthetic}
%# @end deftypefn

classdef Instrument
    % file: @Instrument/Instrument.m
    properties
      name = '';
      id = '';
      description = '';
      value_base = 0;      
      currency = 'EUR';
      asset_class = 'Unknown';   
      type = 'Unknown';      
    end
   
    properties (SetAccess = protected )
      value_stress = [];
      value_mc = [];
      timestep_mc = {};
    end
   
   % Class methods
   methods
      function a = Instrument(tmp_name,tmp_id,tmp_description,tmp_type,tmp_currency,value_base,tmp_asset_class)
         % Instrument Constructor function
         if nargin > 0
            a.name = tmp_name;
            a.id = tmp_id;
            a.description = tmp_description;
            a.type = lower(tmp_type);
            a.value_base = value_base;
            a.currency = tmp_currency;
            a.asset_class = tmp_asset_class;
         end
      end % Instrument
      
      function disp(a)
         % Display a Instrument object
         % Get length of Value vector:
         value_stress_rows = min(rows(a.value_stress),5);
         value_mc_rows = min(rows(a.value_mc),5);
         value_mc_cols = min(length(a.timestep_mc),2);
         fprintf('name: %s\nid: %s\ndescription: %s\ntype: %s\nasset_class: %s\ncurrency: %s\nvalue_base: %8.6f %s\n', ... 
            a.name,a.id,a.description,a.type,a.asset_class,a.currency,a.value_base,a.currency);
         fprintf('value_stress: %8.6f \n',a.value_stress(1:value_stress_rows));
         fprintf('\n');
         % looping via first 5 MC scenario values
         for ( ii = 1 : 1 : value_mc_cols)
            fprintf('MC timestep: %s\n',a.timestep_mc{ii});
            %fprintf('Scenariovalue: %8.2f \n',a.value_mc(1:value_mc_rows,ii));
            fprintf('Scenariovalues:\n[ ')
                for ( jj = 1 : 1 : value_mc_rows)
                    fprintf('%8.6f,\n',a.value_mc(jj,ii));
                end
            fprintf(' ]\n');
         end
        
      end % disp
      
      function obj = set.type(obj,type)
         if ~(strcmpi(type,'cash') || strcmpi(type,'bond') || strcmpi(type,'debt') ...
                    || strcmpi(type,'swaption') ||  strcmpi(type,'option') ...
                    ||  strcmpi(type,'capfloor') || strcmpi(type,'forward') ...
                    || strcmpi(type,'sensitivity') || strcmpi(type,'synthetic') ...
                    || strcmpi(type,'stochastic'))
            error('Type must be either cash, bond, debt, option, swaption, forward, sensitivity, capfloor, stochastic or synthetic')
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
        % printing documentation for Class Instrument (ousourced to dummy function to use documentation behaviour)
        scripts = ['doc_instrument'];
        c = cellstr(scripts);
        for ii = 1:length(c)
            [retval status] = __makeinfo__(get_help_text(c{ii}),format);
        end
        if ( status == 0 )
            if ( printflag == 1) % print to file
                
                if (strcmp(format,'html'))
                    ending = '.html';
                    filename = strcat(path,'functions',ending);
					fid = fopen (filename, 'a');
					retval = strrep( retval, '\', '\\');
                    %replace html title
                    repstring = strcat('<title>', c{ii} ,'</title>');
                    retval = strrep( retval, '<title>Untitled</title>', repstring);
                    % print formatted documentation
					fprintf(fid, retval);
					fprintf(fid, '\n');
					fclose (fid);
                elseif (strcmp(format,'texinfo'))
                    ending = '.texi';
                    filename = strcat(path,'functions',ending);
					fid = fopen (filename, 'a');
					retval = strrep( retval, '\', '\\');
                    % Print texinfo header
					nodestring = strcat('\@node \t', c{ii},'\n')
					fprintf(fid, nodestring);
					sectionstring = strcat('\@section \t', c{ii},'\n')
					fprintf(fid, sectionstring); 
					indexstring = strcat('@cindex \t Function \t', c{ii},'\n');
					fprintf(fid, indexstring);
					% print formatted documentation
					fprintf(fid, retval);
					fprintf(fid, '\n');
					fclose (fid);
                else
                    ending = '.txt';
                end
                 
            else    
                printf('Documentation for Class %s: \n',c{ii}(4:end));
                printf(retval);
                printf('\n');
            end
                     
        else
            disp('There was a problem')
        end
        retval = status;
      end
   end
   
end % classdef
