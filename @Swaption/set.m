% setting attribute values
function obj = set(obj, varargin)
  % A) Specify fieldnames <-> types key/value pairs
  typestruct = struct(...
                'type', 'char' , ...
                'basis', 'numeric' , ...
                'cf_dates', 'numeric' , ...
                'cf_values', 'numeric' , ...
                'vola_spread', 'numeric' , ...
                'value_mc', 'special' , ...
                'timestep_mc', 'special' , ...
                'value_stress', 'special' , ...
                'value_base', 'numeric' , ...
                'name', 'char' , ...
                'id', 'char' , ...
                'sub_type', 'char' , ...
                'asset_class', 'char' , ...
                'currency', 'char' , ...
                'description', 'char' , ...
                'maturity_date', 'date' , ...
                'effective_date', 'date' , ...
                'discount_curve', 'char' , ...
                'und_fixed_leg', 'char' , ...
                'und_floating_leg', 'char' , ...
                'model', 'char' , ...
                'underlying', 'char' , ...
                'vola_surface', 'char' , ...
                'multiplier', 'numeric' , ...
                'und_fixed_value', 'numeric' , ...
                'und_float_value', 'numeric' , ...
                'use_underlyings', 'boolean' , ...
                'spread', 'numeric' , ...
                'strike', 'numeric' , ...
                'spot', 'numeric' , ...
                'vola_sensi', 'numeric' , ...
                'compounding_freq', 'charvnumber' , ...
                'day_count_convention', 'char' , ...
                'compounding_type', 'char' , ...
                'tenor', 'numeric' , ...
                'no_payments', 'numeric'...
               );
  % B) store values in object
  if (length (varargin) < 2 || rem (length (varargin), 2) ~= 0)
    error ('set: expecting property/value pairs');
  end
  
  while (length (varargin) > 1)
    prop = varargin{1};
    prop = lower(prop);
    val = varargin{2};
    varargin(1:2) = [];
    % check, if property is an existing field
    if (sum(strcmpi(prop,fieldnames(typestruct)))==0)
        fprintf('set: not an allowed fieldname >>%s<< with value >>%s<< :\n',prop,any2str(val));
        fieldnames(typestruct)
        error ('set: invalid property of %s class: >>%s<<\n',class(obj),prop);
    end
    % get property type:
    type = typestruct.(prop);
    % input checks and validation
    retval = return_checked_input(obj,val,prop,type);
    % store property in object
    obj.(prop) = retval;
  end
end   
