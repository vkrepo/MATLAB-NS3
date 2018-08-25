classdef OnOffHelper < MlWrapper
    % OnOffHelper This object is used for initiating an on/off application on a set of nodes.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_on_off_helper.html
    
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
            mexOnOffHelper('delete', obj.cppHandle);
        end
        
        function SetAttribute(obj, name, value)
            mexOnOffHelper('SetAttribute', obj.get(), name, value.get());
        end
        
        function obj = OnOffHelper(protocol, address)
            % Creates on/off application with protocol string and address object as input arguments.
            
            obj.cppHandle = mexOnOffHelper('new', strcat('ns3::', protocol), address.get());
        end
        
        function objND = Install(obj, varargin)
            % Installs on/off application on the given node/node-container.
            
            switch(length(varargin))
                case 1
                    objND = mexOnOffHelper('Install', obj.get(), varargin{1}.get());
                    objND = ApplicationContainer.appContCreationFromUint64(objND);
                otherwise
                    objND = 0;
            end
        end
        
        function SetConstantRate(obj, dataRate, varargin)
            % Sets the data rate(in bps) which is given as double value
            
            narginchk(1, 2);
            numvarargs = length(varargin);
            opt_args = {512 };
            opt_args(1:numvarargs) = varargin;
            mexOnOffHelper('SetConstantRate', obj.get(), dataRate, opt_args{1});
        end
    end
end
