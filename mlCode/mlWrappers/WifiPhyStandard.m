classdef WifiPhyStandard < uint32
    % WifiPhyStandard This object models NS-3 enumarations for WiFi standard.
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    enumeration
        WIFI_PHY_STANDARD_80211a (0)
        WIFI_PHY_STANDARD_80211b (1)
        WIFI_PHY_STANDARD_80211g (2)
        WIFI_PHY_STANDARD_80211_10MHZ (3)
        WIFI_PHY_STANDARD_80211_5MHZ (4)
        WIFI_PHY_STANDARD_holland (5)
        WIFI_PHY_STANDARD_80211n_2_4GHZ (6)
        WIFI_PHY_STANDARD_80211n_5GHZ (7)
        WIFI_PHY_STANDARD_80211ac (8)
        WIFI_PHY_STANDARD_UNSPECIFIED (9)
    end
    
    methods (Static)
        function value = getStandard(standard)
            % NS-3 enumaration value for WiFi standard is returned on being given the WiFi standard as a string.
            
            switch(standard)
                case '802.11a'
                    value = WifiPhyStandard.WIFI_PHY_STANDARD_80211a;
                case '802.11b'
                    value = WifiPhyStandard.WIFI_PHY_STANDARD_80211b;
                case '802.11g'
                    value = WifiPhyStandard.WIFI_PHY_STANDARD_80211g;
                case '802.11n-2.4GHz'
                    value = WifiPhyStandard.WIFI_PHY_STANDARD_80211n_2_4_GHZ;
                case '802.11n-5GHz'
                    value = WifiPhyStandard.WIFI_PHY_STANDARD_80211n_5GHZ;
                case '802.11ac'
                    value = WifiPhyStandard.WIFI_PHY_STANDARD_80211ac;
                otherwise
                    value = WifiPhyStandard.WIFI_PHY_STANDARD_80211a;
            end
        end
    end
end
