classdef MobilityHelper < handle
    % MobilityHelper This object is used to assign position and mobility model to nodes.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_mobility_helper.html
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties ( Access = public, Hidden = true)
        cppHandle
    end
    
    methods
        function delete (obj)
            mexMobilityHelper ('delete', obj.cppHandle);
        end
        
        function set(obj, val)
            obj.cppHandle = val;
        end
        
        function val = get(obj)
            val = obj.cppHandle;
        end
        
        function obj = MobilityHelper ()
            obj.cppHandle = mexMobilityHelper ('new');
        end
        
        function SetPositionAllocator (obj, name, varargin)
            narginchk(1, 19);
            numvarargs = length(varargin);
            opt_args = {'' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue()};
            opt_args(1:numvarargs) = varargin;
            mexMobilityHelper ('SetPositionAllocator', obj.get() , strcat('ns3::', name), opt_args{1}, opt_args{2}.get(), opt_args{3}, opt_args{4}.get(), opt_args{5}, opt_args{6}.get(), opt_args{7}, opt_args{8}.get(), opt_args{9}, opt_args{10}.get(), opt_args{11}, opt_args{12}.get(), opt_args{13}, opt_args{14}.get(), opt_args{15}, opt_args{16}.get(), opt_args{17}, opt_args{18}.get());
        end
        
        function SetMobilityModel (obj, type)
            mexMobilityHelper ('SetMobilityModel', obj.cppHandle, strcat('ns3::', type));
        end
        
        function PushReferenceMobilityModel(obj)
        end
        
        function PopReferenceMobilityModel (obj)
        end
        
        function objND = GetMobilityModelType (obj)
            objND = 0;
        end
        
        function Install (obj, varargin)
            % Installs the mobility helper object on node/node-container.
            switch(length(varargin))
                case 1
                    mexMobilityHelper ('Install', obj.get(), varargin{1}.get());
                otherwise
                    
            end
        end
        
        function InstallAll (obj)
        end
        
        function objND = AssignStreams (obj, c, stream)
            objND = 0;
        end
    end
    
    methods(Static)
        function EnableAscii (varargin)
            switch (nargin)
                case 2
                otherwise
                    
            end
        end
        
        function EnableAsciiAll (stream)
        end
        
        function objND = GetDistanceSquaredBetween (n1, n2)
            objND = 0;
        end
    end
end
