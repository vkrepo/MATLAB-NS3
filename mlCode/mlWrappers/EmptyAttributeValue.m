classdef EmptyAttributeValue < MlWrapper
    % EmptyAttributeValue This object holds a null value. This can be used for setting null-type of attributes to NS3 models.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_empty_attribute_value.html
    
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
            mexEmptyAttributeValue('delete', obj.cppHandle);
        end
        
        function obj = EmptyAttributeValue()
            obj.cppHandle = mexEmptyAttributeValue('new');
        end
    end
end