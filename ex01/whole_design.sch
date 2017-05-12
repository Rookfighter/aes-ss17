<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="freq_out(2:0)" />
        <signal name="XLXN_2" />
        <signal name="clk" />
        <signal name="led" />
        <signal name="XLXN_5" />
        <signal name="XLXN_6(2:0)" />
        <signal name="XLXN_7" />
        <port polarity="Output" name="freq_out(2:0)" />
        <port polarity="Input" name="clk" />
        <port polarity="Output" name="led" />
        <blockdef name="freq_controller">
            <timestamp>2017-5-12T15:21:21</timestamp>
            <rect width="256" x="64" y="-64" height="64" />
            <rect width="64" x="320" y="-44" height="24" />
            <line x2="384" y1="-32" y2="-32" x1="320" />
        </blockdef>
        <blockdef name="ledblinker">
            <timestamp>2017-5-12T15:21:15</timestamp>
            <rect width="256" x="64" y="-128" height="128" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <line x2="384" y1="-96" y2="-96" x1="320" />
        </blockdef>
        <block symbolname="freq_controller" name="XLXI_1">
            <blockpin signalname="freq_out(2:0)" name="freq(2:0)" />
        </block>
        <block symbolname="ledblinker" name="XLXI_2">
            <blockpin signalname="clk" name="clk" />
            <blockpin signalname="freq_out(2:0)" name="freq(2:0)" />
            <blockpin signalname="led" name="led" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <instance x="1296" y="1136" name="XLXI_2" orien="R0">
        </instance>
        <branch name="freq_out(2:0)">
            <wire x2="1152" y1="1104" y2="1104" x1="928" />
            <wire x2="1296" y1="1104" y2="1104" x1="1152" />
            <wire x2="1152" y1="1104" y2="1264" x1="1152" />
            <wire x2="1168" y1="1264" y2="1264" x1="1152" />
        </branch>
        <branch name="clk">
            <wire x2="1296" y1="1040" y2="1040" x1="1264" />
        </branch>
        <iomarker fontsize="28" x="1264" y="1040" name="clk" orien="R180" />
        <branch name="led">
            <wire x2="1712" y1="1040" y2="1040" x1="1680" />
        </branch>
        <iomarker fontsize="28" x="1712" y="1040" name="led" orien="R0" />
        <instance x="544" y="1136" name="XLXI_1" orien="R0">
        </instance>
        <iomarker fontsize="28" x="1168" y="1264" name="freq_out(2:0)" orien="R0" />
    </sheet>
</drawing>