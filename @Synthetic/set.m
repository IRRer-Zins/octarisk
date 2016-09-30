% setting attribute values
function obj = set(obj, varargin)
  % A) Specify fieldnames <-> types key/value pairs
  typestruct = struct(
                'type', 'char' , ...
                'basis', 'numeric' , ...
                'value_mc', 'numeric' , ...
                'timestep_mc', 'special' , ...
                'value_stress', 'special' , ...
                'value_base', 'numeric' , ...
                'name', 'char' , ...
                'id', 'char' , ...
                'sub_type', 'char' , ...
                'valuation_date', 'char' , ...
                'asset_class', 'char' , ...
                'currency', 'char' , ...
                'description', 'char' , ...
                'cf_values', 'numeric' , ...
                'cf_dates', 'numeric' , ...
                'instruments', 'cell' , ...
                'weights', 'numeric'
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