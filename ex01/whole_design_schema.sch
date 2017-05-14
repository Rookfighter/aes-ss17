<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="btn0" />
        <signal name="btn1" />
        <signal name="XLXN_13" />
        <signal name="freq_out(2:0)" />
        <signal name="XLXN_15" />
        <signal name="XLXN_16" />
        <signal name="XLXN_17" />
        <signal name="rst" />
        <signal name="clk" />
        <signal name="led" />
        <port polarity="Input" name="btn0" />
        <port polarity="Input" name="btn1" />
        <port polarity="Output" name="freq_out(2:0)" />
        <port polarity="Input" name="rst" />
        <port polarity="Input" name="clk" />
        <port polarity="Output" name="led" />
        <blockdef name="freq_controller">
            <timestamp>2017-5-14T13:43:18</timestamp>
            <rect width="256" x="64" y="-256" height="256" />
            <line x2="0" y1="-224" y2="-224" x1="64" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <rect width="64" x="320" y="-236" height="24" />
            <line x2="384" y1="-224" y2="-224" x1="320" />
        </blockdef>
        <blockdef name="ledblinker">
            <timestamp>2017-5-14T13:43:28</timestamp>
            <rect width="256" x="64" y="-192" height="192" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <line x2="384" y1="-160" y2="-160" x1="320" />
        </blockdef>
        <block symbolname="freq_controller" name="XLXI_1">
            <blockpin signalname="rst" name="rst" />
            <blockpin signalname="clk" name="clk" />
            <blockpin signalname="btn0" name="btn0" />
            <blockpin signalname="btn1" name="btn1" />
            <blockpin signalname="freq_out(2:0)" name="freq(2:0)" />
        </block>
        <block symbolname="ledblinker" name="XLXI_2">
            <blockpin signalname="rst" name="rst" />
            <blockpin signalname="clk" name="clk" />
            <blockpin signalname="freq_out(2:0)" name="freq(2:0)" />
            <blockpin signalname="led" name="led" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <instance x="1296" y="1136" name="XLXI_2" orien="R0">
        </instance>
        <iomarker fontsize="28" x="1232" y="1312" name="freq_out(2:0)" orien="R0" />
        <branch name="btn1">
            <wire x2="608" y1="1200" y2="1200" x1="464" />
            <wire x2="624" y1="1200" y2="1200" x1="608" />
        </branch>
        <branch name="freq_out(2:0)">
            <wire x2="1104" y1="1008" y2="1008" x1="1008" />
            <wire x2="1104" y1="1008" y2="1104" x1="1104" />
            <wire x2="1152" y1="1104" y2="1104" x1="1104" />
            <wire x2="1296" y1="1104" y2="1104" x1="1152" />
            <wire x2="1152" y1="1104" y2="1312" x1="1152" />
            <wire x2="1232" y1="1312" y2="1312" x1="1152" />
        </branch>
        <instance x="624" y="1232" name="XLXI_1" orien="R0">
        </instance>
        <branch name="btn0">
            <wire x2="608" y1="1136" y2="1136" x1="432" />
            <wire x2="624" y1="1136" y2="1136" x1="608" />
        </branch>
        <iomarker fontsize="28" x="432" y="1136" name="btn0" orien="R180" />
        <iomarker fontsize="28" x="464" y="1200" name="btn1" orien="R180" />
        <branch name="rst">
            <wire x2="560" y1="912" y2="912" x1="400" />
            <wire x2="560" y1="912" y2="1008" x1="560" />
            <wire x2="624" y1="1008" y2="1008" x1="560" />
            <wire x2="1024" y1="912" y2="912" x1="560" />
            <wire x2="1024" y1="912" y2="976" x1="1024" />
            <wire x2="1296" y1="976" y2="976" x1="1024" />
        </branch>
        <branch name="clk">
            <wire x2="496" y1="1024" y2="1024" x1="400" />
            <wire x2="496" y1="1024" y2="1056" x1="496" />
            <wire x2="512" y1="1056" y2="1056" x1="496" />
            <wire x2="512" y1="1056" y2="1072" x1="512" />
            <wire x2="624" y1="1072" y2="1072" x1="512" />
            <wire x2="496" y1="1056" y2="1312" x1="496" />
            <wire x2="1056" y1="1312" y2="1312" x1="496" />
            <wire x2="1056" y1="1040" y2="1312" x1="1056" />
            <wire x2="1296" y1="1040" y2="1040" x1="1056" />
        </branch>
        <iomarker fontsize="28" x="400" y="1024" name="clk" orien="R180" />
        <iomarker fontsize="28" x="400" y="912" name="rst" orien="R180" />
        <branch name="led">
            <wire x2="1712" y1="976" y2="976" x1="1680" />
        </branch>
        <iomarker fontsize="28" x="1712" y="976" name="led" orien="R0" />
    </sheet>
</drawing>