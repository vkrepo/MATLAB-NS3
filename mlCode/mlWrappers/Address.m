classdef Address < MlWrapper
    % Address This object holds a MAC address or IP address.
    % More Details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_address.html
    
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
            mexAddress('delete', obj.cppHandle);
        end
        
        function objND = IsInvalid(obj)
            objND = mexAddress('IsInvalid', obj.get());
        end
        
        function objND = GetLength(obj)
            objND = mexAddress('GetLength', obj.get());
        end
        
        function obj = Address(varargin)
            switch(length(varargin))
                case 0
                    obj.cppHandle = mexAddress('new');
                case 3
                    obj.cppHandle = mexAddress('new', varargin{1}.get(), varargin{2}.get(), varargin{3}.get());
                case 1
                    obj.cppHandle = mexAddress('new', varargin{1}.get());
                otherwise
                    obj.cppHandle = 0;
            end
        end
        
    end
    
    methods (Static)
        function objND = addrCreationFromUint64(val)
            % MATLAB wrapper around c++ Address object.
            
            objND = Address(0, 0, 0, 0);
            objND.cppHandle = val;
        end
    end
end
