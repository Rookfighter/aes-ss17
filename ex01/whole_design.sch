<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="freq_out(2:0)" />
        <signal name="clk" />
        <signal name="led" />
        <signal name="XLXN_8" />
        <signal name="rst" />
        <signal name="XLXN_10" />
        <signal name="XLXN_11" />
        <signal name="XLXN_12" />
        <signal name="btn0" />
        <signal name="btn1" />
        <port polarity="Output" name="freq_out(2:0)" />
        <port polarity="Input" name="clk" />
        <port polarity="Output" name="led" />
        <port polarity="Input" name="rst" />
        <port polarity="Input" name="btn0" />
        <port polarity="Input" name="btn1" />
        <blockdef name="freq_controller">
            <timestamp>2017-5-14T13:43:18</timestamp>
            <line x2="0" y1="32" y2="32" x1="64" />
            <line x2="0" y1="96" y2="96" x1="64" />
            <line x2="0" y1="160" y2="160" x1="64" />
            <line x2="0" y1="224" y2="224" x1="64" />
            <rect width="64" x="320" y="-44" height="24" />
            <line x2="384" y1="-32" y2="-32" x1="320" />
            <rect width="256" x="64" y="-64" height="320" />
        </blockdef>
        <blockdef name="ledblinker">
            <timestamp>2017-5-14T13:43:28</timestamp>
            <line x2="0" y1="32" y2="32" x1="64" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <line x2="384" y1="-96" y2="-96" x1="320" />
            <rect width="256" x="64" y="-128" height="192" />
        </blockdef>
        <block symbolname="freq_controller" name="XLXI_1">
            <blockpin signalname="freq_out(2:0)" name="freq(2:0)" />
            <blockpin signalname="rst" name="rst" />
            <blockpin signalname="clk" name="clk" />
            <blockpin signalname="btn0" name="btn0" />
            <blockpin signalname="btn1" name="btn1" />
        </block>
        <block symbolname="ledblinker" name="XLXI_2">
            <blockpin signalname="clk" name="clk" />
            <blockpin signalname="freq_out(2:0)" name="freq(2:0)" />
            <blockpin signalname="led" name="led" />
            <blockpin signalname="rst" name="rst" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <branch name="freq_out(2:0)">
            <wire x2="1152" y1="1104" y2="1104" x1="1072" />
            <wire x2="1296" y1="1104" y2="1104" x1="1152" />
            <wire x2="1152" y1="1104" y2="1312" x1="1152" />
            <wire x2="1232" y1="1312" y2="1312" x1="1152" />
        </branch>
        <branch name="clk">
            <wire x2="560" y1="912" y2="912" x1="496" />
            <wire x2="1280" y1="912" y2="912" x1="560" />
            <wire x2="1280" y1="912" y2="1040" x1="1280" />
            <wire x2="1296" y1="1040" y2="1040" x1="1280" />
            <wire x2="560" y1="912" y2="1232" x1="560" />
            <wire x2="688" y1="1232" y2="1232" x1="560" />
        </branch>
        <branch name="led">
            <wire x2="1712" y1="1040" y2="1040" x1="1680" />
        </branch>
        <iomarker fontsize="28" x="1712" y="1040" name="led" orien="R0" />
        <instance x="688" y="1136" name="XLXI_1" orien="R0">
        </instance>
        <iomarker fontsize="28" x="496" y="912" name="clk" orien="R180" />
        <branch name="rst">
            <wire x2="400" y1="1296" y2="1296" x1="240" />
            <wire x2="400" y1="1296" y2="1472" x1="400" />
            <wire x2="1136" y1="1472" y2="1472" x1="400" />
            <wire x2="688" y1="1168" y2="1168" x1="400" />
            <wire x2="400" y1="1168" y2="1296" x1="400" />
            <wire x2="1136" y1="1168" y2="1472" x1="1136" />
            <wire x2="1296" y1="1168" y2="1168" x1="1136" />
        </branch>
        <instance x="1296" y="1136" name="XLXI_2" orien="R0">
        </instance>
        <iomarker fontsize="28" x="1232" y="1312" name="freq_out(2:0)" orien="R0" />
        <branch name="btn0">
            <wire x2="688" y1="1296" y2="1296" x1="656" />
        </branch>
        <iomarker fontsize="28" x="656" y="1296" name="btn0" orien="R180" />
        <branch name="btn1">
            <wire x2="688" y1="1360" y2="1360" x1="656" />
        </branch>
        <iomarker fontsize="28" x="656" y="1360" name="btn1" orien="R180" />
        <iomarker fontsize="28" x="240" y="1296" name="rst" orien="R180" />
    </sheet>
</drawing>