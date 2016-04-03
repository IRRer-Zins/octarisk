function obj = calc_vola_spread(swaption,vola_riskfactor,discount_curve,tmp_vola_surf_obj,valuation_date)
    obj = swaption;
    if ( nargin < 4)
        error("Error: No discount curve or vola surface set. Aborting.");
    endif
    if ( nargin < 5)
        valuation_date = today;
    endif
    if (ischar(valuation_date))
        valuation_date = datenum(valuation_date);
    endif
    % Get discount curve nodes and rate
        tmp_nodes        = discount_curve.get('nodes');
        tmp_rates_base   = discount_curve.getValue('base');
    tmp_type = obj.sub_type;
    % Get Call or Putflag
    %fprintf("==============================\n");
    if ( strcmp(tmp_type,'SWAPT_EUR_PAY') == 1 )
        call_flag = 1;
        moneyness_exponent = 1;
    else
        call_flag = 0;
        moneyness_exponent = -1;
    end
     
    % Get input variables
    tmp_dtm                  = (datenum(obj.maturity_date) - valuation_date - 1); 
    tmp_rf_rate_base         = interpolate_curve(tmp_nodes,tmp_rates_base,tmp_dtm ) .+ obj.spread;
    
    
    if ( tmp_dtm < 0 )
        tmp_impl_vola_spread    = 0;
        theo_value_base         = 0;
    else
        % Valuation: Black-76 Modell:
        tmp_spot            = obj.spot;
        tmp_strike          = obj.strike;
        tmp_value           = obj.value_base;
        theo_value_base     = tmp_value;
        tmp_multiplier      = obj.multiplier;
        tmp_swap_tenor      = obj.tenor;
        tmp_swap_no_pmt     = obj.no_payments;
        tmp_model           = obj.model;

                                    
        % Get underlying yield rates:
        tmp_forward_base            = get_forward_rate(tmp_nodes,tmp_rates_base,tmp_dtm,tmp_swap_tenor);
        tmp_moneyness_base          = (tmp_forward_base ./tmp_strike).^moneyness_exponent;
                
        % get implied volatility spread (choose offset to vola, that tmp_value == option_bs with input of appropriate vol):
        tmp_indexvol_base           = tmp_vola_surf_obj.getValue(tmp_swap_tenor,tmp_dtm,tmp_moneyness_base);

        % Calculate Swaption base value and implied spread
        if ( strcmp(tmp_model,'BLACK76'))
            tmp_swaptionvalue_base      = swaption_black76(call_flag,tmp_forward_base,tmp_strike,tmp_dtm,tmp_rf_rate_base,tmp_indexvol_base,tmp_swap_no_pmt,tmp_swap_tenor) .* tmp_multiplier;
        else
            tmp_swaptionvalue_base      = swaption_bachelier(call_flag,tmp_forward_base,tmp_strike,tmp_dtm,tmp_rf_rate_base,tmp_indexvol_base,tmp_swap_no_pmt,tmp_swap_tenor) .* tmp_multiplier;
        end
        tmp_impl_vola_spread        = calibrate_swaption(call_flag,tmp_forward_base,tmp_strike,tmp_dtm,tmp_rf_rate_base,tmp_indexvol_base,tmp_swap_no_pmt,tmp_swap_tenor,tmp_multiplier,tmp_value,tmp_model);
        tmp_swaptionvalue_base
        tmp_impl_vola_spread
        % error handling of calibration:
        if ( tmp_impl_vola_spread < -98 )
            disp(" Calibration failed with Retcode 99. Setting market value to THEO/Value");
            theo_value_base = tmp_swaptionvalue_base;
            tmp_impl_vola_spread    = 0; 
        else
            %disp("Calibration seems to be successful.. checking");
            if ( strcmp(tmp_model,'BLACK76'))
                tmp_new_val      = swaption_black76(call_flag,tmp_forward_base,tmp_strike,tmp_dtm,tmp_rf_rate_base,tmp_indexvol_base.+ tmp_impl_vola_spread,tmp_swap_no_pmt,tmp_swap_tenor) .* tmp_multiplier;
            else
                tmp_new_val      = swaption_bachelier(call_flag,tmp_forward_base,tmp_strike,tmp_dtm,tmp_rf_rate_base,tmp_indexvol_base.+ tmp_impl_vola_spread,tmp_swap_no_pmt,tmp_swap_tenor) .* tmp_multiplier;
            end
        
            if ( abs(tmp_value - tmp_new_val) < 0.05 )
                %disp("Calibration successful.");
                theo_value_base = tmp_value;
            else
                disp(" Calibration failed, although it converged.. Setting market value to THEO/Value");
                theo_value_base = tmp_swaptionvalue_base;
                tmp_impl_vola_spread = 0; 
            endif
        endif
     
    endif   % close loop if tmp_dtm < 0
    
      
    % store theo_value vector in appropriate class property
    obj.vola_spread = tmp_impl_vola_spread;
    obj.value_base = theo_value_base;
endfunction




