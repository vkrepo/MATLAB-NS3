classdef QosWaveMacHelper < MlWrapper & WifiMacHelper
    % QosWaveMacHelper This object models the functionality of a Qos WAVE MAC.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_qos_wave_mac_helper.html
    
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
            mexQosWaveMacHelper('delete', obj.cppHandle);
        end
        
        function obj = QosWaveMacHelper(varargin)
            switch (length(varargin))
                case 0
                    obj.cppHandle = mexQosWaveMacHelper('new');
                otherwise
                    obj.cppHandle = 0;
            end
        end
        function SetType(obj, type, varargin)
            narginchk(1, 23);
            numvarargs = length(varargin);
            opt_args = {'' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() };
            opt_args(1:numvarargs) = varargin;
            mexQosWaveMacHelper('SetType', obj.get(), type, opt_args{1}, opt_args{2}.get(), opt_args{3}, opt_args{4}.get(), opt_args{5}, opt_args{6}.get(), opt_args{7}, opt_args{8}.get(), opt_args{9}, opt_args{10}.get(), opt_args{11}, opt_args{12}.get(), opt_args{13}, opt_args{14}.get(), opt_args{15}, opt_args{16}.get(), opt_args{17}, opt_args{18}.get(), opt_args{19}, opt_args{20}.get(), opt_args{21}, opt_args{22}.get());
        end
        
    end
    
    methods (Static)
        function objND = Default()
            objND = QosWaveMacHelper(0);
            objND.cppHandle = mexQosWaveMacHelper('Default');
        end
        
    end
end