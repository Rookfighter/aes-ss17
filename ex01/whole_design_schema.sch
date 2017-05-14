<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="freq(2:0)" />
        <signal name="clk" />
        <signal name="btn0" />
        <signal name="btn1" />
        <signal name="led" />
        <signal name="rst" />
        <signal name="XLXN_26" />
        <port polarity="Output" name="freq(2:0)" />
        <port polarity="Input" name="clk" />
        <port polarity="Input" name="btn0" />
        <port polarity="Input" name="btn1" />
        <port polarity="Output" name="led" />
        <port polarity="Input" name="rst" />
        <blockdef name="freq_controller">
            <timestamp>2017-5-14T16:47:46</timestamp>
            <rect width="256" x="64" y="-256" height="256" />
            <line x2="0" y1="-224" y2="-224" x1="64" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <rect width="64" x="320" y="-236" height="24" />
            <line x2="384" y1="-224" y2="-224" x1="320" />
        </blockdef>
        <blockdef name="ledblinker">
            <timestamp>2017-5-14T16:47:51</timestamp>
            <rect width="256" x="64" y="-192" height="192" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <line x2="384" y1="-160" y2="-160" x1="320" />
        </blockdef>
        <blockdef name="inv">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-32" y2="-32" x1="0" />
            <line x2="160" y1="-32" y2="-32" x1="224" />
            <line x2="128" y1="-64" y2="-32" x1="64" />
            <line x2="64" y1="-32" y2="0" x1="128" />
            <line x2="64" y1="0" y2="-64" x1="64" />
            <circle r="16" cx="144" cy="-32" />
        </blockdef>
        <block symbolname="freq_controller" name="XLXI_3">
            <blockpin signalname="XLXN_26" name="rst" />
            <blockpin signalname="clk" name="clk" />
            <blockpin signalname="btn0" name="btn0" />
            <blockpin signalname="btn1" name="btn1" />
            <blockpin signalname="freq(2:0)" name="freq(2:0)" />
        </block>
        <block symbolname="ledblinker" name="XLXI_4">
            <blockpin signalname="XLXN_26" name="rst" />
            <blockpin signalname="clk" name="clk" />
            <blockpin signalname="freq(2:0)" name="freq(2:0)" />
            <blockpin signalname="led" name="led" />
        </block>
        <block symbolname="inv" name="XLXI_6">
            <blockpin signalname="rst" name="I" />
            <blockpin signalname="XLXN_26" name="O" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <instance x="1616" y="992" name="XLXI_4" orien="R0">
        </instance>
        <branch name="freq(2:0)">
            <wire x2="1360" y1="960" y2="960" x1="1088" />
            <wire x2="1616" y1="960" y2="960" x1="1360" />
            <wire x2="1360" y1="960" y2="1120" x1="1360" />
            <wire x2="1440" y1="1120" y2="1120" x1="1360" />
        </branch>
        <instance x="704" y="1184" name="XLXI_3" orien="R0">
        </instance>
        <branch name="clk">
            <wire x2="640" y1="1024" y2="1024" x1="480" />
            <wire x2="704" y1="1024" y2="1024" x1="640" />
            <wire x2="640" y1="896" y2="1024" x1="640" />
            <wire x2="1616" y1="896" y2="896" x1="640" />
        </branch>
        <iomarker fontsize="28" x="480" y="1024" name="clk" orien="R180" />
        <branch name="btn0">
            <wire x2="704" y1="1088" y2="1088" x1="672" />
        </branch>
        <iomarker fontsize="28" x="672" y="1088" name="btn0" orien="R180" />
        <branch name="btn1">
            <wire x2="704" y1="1152" y2="1152" x1="672" />
        </branch>
        <iomarker fontsize="28" x="672" y="1152" name="btn1" orien="R180" />
        <branch name="led">
            <wire x2="2032" y1="832" y2="832" x1="2000" />
        </branch>
        <iomarker fontsize="28" x="2032" y="832" name="led" orien="R0" />
        <iomarker fontsize="28" x="1440" y="1120" name="freq(2:0)" orien="R0" />
        <instance x="256" y="784" name="XLXI_6" orien="R0" />
        <branch name="rst">
            <wire x2="256" y1="752" y2="752" x1="224" />
        </branch>
        <iomarker fontsize="28" x="224" y="752" name="rst" orien="R180" />
        <branch name="XLXN_26">
            <wire x2="592" y1="752" y2="752" x1="480" />
            <wire x2="592" y1="752" y2="960" x1="592" />
            <wire x2="704" y1="960" y2="960" x1="592" />
            <wire x2="1104" y1="752" y2="752" x1="592" />
            <wire x2="1104" y1="752" y2="832" x1="1104" />
            <wire x2="1616" y1="832" y2="832" x1="1104" />
        </branch>
    </sheet>
</drawing>