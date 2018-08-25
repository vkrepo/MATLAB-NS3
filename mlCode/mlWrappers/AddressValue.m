classdef AddressValue < MlWrapper
    % AddressValue This object holds a MAC address or IP Address.
    % This can be used for setting address-type of attributes to NS3 models.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_address_value.html
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties ( Access = private, Hidden = true)
        cppHandle
    end
    
    methods
        function set(obj, val)
            obj.cppHandle = val;
        end
        
        function val = get(obj)
            val = obj.cppHandle;
        end
        
        function delete(obj)
            mexAddressValue('delete', obj.cppHandle);
        end
        
        function obj = AddressValue(varargin)
            switch(length(varargin))
                case 0
                    obj.cppHandle = mexAddressValue('new');
                case 1
                    obj.cppHandle = mexAddressValue('new', varargin{1}.get());
                otherwise
                    obj.cppHandle = 0;
            end
        end
    end
end