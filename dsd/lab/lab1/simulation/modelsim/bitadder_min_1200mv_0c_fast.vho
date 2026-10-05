-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- VENDOR "Altera"
-- PROGRAM "Quartus II 64-Bit"
-- VERSION "Version 13.1.0 Build 162 10/23/2013 SJ Web Edition"

-- DATE "09/24/2026 18:51:11"

-- 
-- Device: Altera EP4CE115F29C7 Package FBGA780
-- 

-- 
-- This VHDL file should be used for ModelSim-Altera (VHDL) only
-- 

LIBRARY CYCLONEIVE;
LIBRARY IEEE;
USE CYCLONEIVE.CYCLONEIVE_COMPONENTS.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY 	bitadder IS
    PORT (
	A : IN std_logic;
	B : IN std_logic;
	C : IN std_logic;
	sum : BUFFER std_logic;
	cout : BUFFER std_logic
	);
END bitadder;

-- Design Ports Information
-- sum	=>  Location: PIN_W7,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- cout	=>  Location: PIN_W3,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- A	=>  Location: PIN_Y6,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- B	=>  Location: PIN_Y5,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- C	=>  Location: PIN_W4,	 I/O Standard: 2.5 V,	 Current Strength: Default


ARCHITECTURE structure OF bitadder IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL devoe : std_logic := '1';
SIGNAL devclrn : std_logic := '1';
SIGNAL devpor : std_logic := '1';
SIGNAL ww_devoe : std_logic;
SIGNAL ww_devclrn : std_logic;
SIGNAL ww_devpor : std_logic;
SIGNAL ww_A : std_logic;
SIGNAL ww_B : std_logic;
SIGNAL ww_C : std_logic;
SIGNAL ww_sum : std_logic;
SIGNAL ww_cout : std_logic;
SIGNAL \sum~output_o\ : std_logic;
SIGNAL \cout~output_o\ : std_logic;
SIGNAL \B~input_o\ : std_logic;
SIGNAL \A~input_o\ : std_logic;
SIGNAL \C~input_o\ : std_logic;
SIGNAL \sum~0_combout\ : std_logic;
SIGNAL \cout~0_combout\ : std_logic;

BEGIN

ww_A <= A;
ww_B <= B;
ww_C <= C;
sum <= ww_sum;
cout <= ww_cout;
ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;

-- Location: IOOBUF_X0_Y12_N23
\sum~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \sum~0_combout\,
	devoe => ww_devoe,
	o => \sum~output_o\);

-- Location: IOOBUF_X0_Y13_N2
\cout~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \cout~0_combout\,
	devoe => ww_devoe,
	o => \cout~output_o\);

-- Location: IOIBUF_X0_Y12_N15
\B~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_B,
	o => \B~input_o\);

-- Location: IOIBUF_X0_Y13_N8
\A~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_A,
	o => \A~input_o\);

-- Location: IOIBUF_X0_Y14_N8
\C~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_C,
	o => \C~input_o\);

-- Location: LCCOMB_X1_Y13_N16
\sum~0\ : cycloneive_lcell_comb
-- Equation(s):
-- \sum~0_combout\ = \B~input_o\ $ (\A~input_o\ $ (\C~input_o\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1001011010010110",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \B~input_o\,
	datab => \A~input_o\,
	datac => \C~input_o\,
	combout => \sum~0_combout\);

-- Location: LCCOMB_X1_Y13_N2
\cout~0\ : cycloneive_lcell_comb
-- Equation(s):
-- \cout~0_combout\ = (\B~input_o\ & ((\A~input_o\) # (\C~input_o\))) # (!\B~input_o\ & (\A~input_o\ & \C~input_o\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1110100011101000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \B~input_o\,
	datab => \A~input_o\,
	datac => \C~input_o\,
	combout => \cout~0_combout\);

ww_sum <= \sum~output_o\;

ww_cout <= \cout~output_o\;
END structure;


