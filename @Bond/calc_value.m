function obj = calc_value(bond,valuation_date,discount_curve,value_type)
  obj = bond;
   if ( nargin < 3)
        error('Error: No  discount curve set. Aborting.');
   end
   if ( nargin < 4)
        error('No value_type set. [stress,1d,10d,...]');
   end

    % Get reference curve nodes and rate
        tmp_nodes    = discount_curve.get('nodes');
        tmp_rates    = discount_curve.getValue(value_type);
    
    % Get interpolation method and other curve related attributes
        tmp_interp_discount = discount_curve.get('method_interpolation');
        tmp_curve_dcc       = discount_curve.get('day_count_convention');
        tmp_curve_basis     = discount_curve.get('basis');
        tmp_curve_comp_type = discount_curve.get('compounding_type');
        tmp_curve_comp_freq = discount_curve.get('compounding_freq');
        
    % Get cf values and dates
    tmp_cashflow_dates  = obj.get('cf_dates');
    tmp_cashflow_values = obj.getCF(value_type);
    
    % Get bond related basis and conventions
    basis       = bond.get('basis');
    comp_type   = bond.get('compounding_type');
    comp_freq   = bond.get('compounding_freq');
    
    if ( columns(tmp_cashflow_values) == 0 || rows(tmp_cashflow_values) == 0 )
        error('No cash flow values set. CF rollout done?');    
    end
    % calculate value according to pricing formula
    [theo_value MacDur] = pricing_npv(valuation_date, tmp_cashflow_dates, ...
                                    tmp_cashflow_values, bond.soy, ...
                                    tmp_nodes, tmp_rates, basis, comp_type, ...
                                    comp_freq, tmp_interp_discount, ...
                                    tmp_curve_comp_type, tmp_curve_basis, ...
                                    tmp_curve_comp_freq);
                                    
    % store theo_value vector in appropriate class property
    if ~isreal(theo_value)
        obj.id
        theo_value(1:min(length(theo_value),100))     
        error('theo_value of bond is not real ')
    end
    if ( regexp(value_type,'stress'))
        obj = obj.set('value_stress',theo_value);
    elseif ( strcmp(value_type,'base'))
        obj = obj.set('value_base',theo_value(1));
        obj.mac_duration = MacDur(1);
        obj.mod_duration = (MacDur(1) ./ (1 + obj.coupon_rate  ...
                                          ./ obj.compounding_freq)) ./100;
    else
        obj = obj.set('timestep_mc',value_type);
        obj = obj.set('value_mc',theo_value);
    end
   
end


