#require "mscorlib"
#require "System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
#require "System.Text, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
#require "System.Xml, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"


#module NCI.DCEG.BCRA.Engine
class RiskCalculator
  ## of covariate patterns in GAIL model
  # matrix
  #this is to store beta values
  #private double[,] bet2 = new double[8, 3];
  #private double[,] rmu2 = new double[14, 6];//[14,6];
  #private double[,] rlan2 = new double[14, 6]; //[14,6];[84] #[14,6]; #[14,6];[84] #[12]
  def initialize
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG

    @num_cov_patt_in_gail_model = 216
    @bet2 = Array.new(15) {Array.new(14)}#Array.CreateInstance(System::Double, 8, 12)
    @bet =  Array.new#Array.CreateInstance(System::Double, 8)
    @rf =  Array.new#Array.CreateInstance(System::Double, 2)
    @abs =  Array.new#Array.CreateInstance(System::Double, 216)
    @rlan =  Array.new#Array.CreateInstance(System::Double, 14)
    @rmu =  Array.new#Array.CreateInstance(System::Double, 14)
    @sumb =  Array.new#Array.CreateInstance(System::Double, 216)
    @sumbb = Array.new#Array.CreateInstance(System::Double, 216)
    @tvar = Array.new#Array.CreateInstance(System::Double, 15)
    @rmu2 = Array.new(15) {Array.new(14)} #Array.CreateInstance(System::Double, 14, 12)
    @rlan2 =Array.new(15) {Array.new(14)} #Array.CreateInstance(System::Double, 14, 12)
    @rf2 = Array.new(15) {Array.new(14)}#Array.CreateInstance(System::Double, 2, 13)
    self.initialize_calc
  end

  def initialize_calc
    # age categories boundaries
    @tvar[0] = 20.0
    @tvar[1] = 25.0
    @tvar[2] = 30.0
    @tvar[3] = 35.0
    @tvar[4] = 40.0
    @tvar[5] = 45.0
    @tvar[6] = 50.0
    @tvar[7] = 55.0
    @tvar[8] = 60.0
    @tvar[9] = 65.0
    @tvar[10] = 70.0
    @tvar[11] = 75.0
    @tvar[12] = 80.0
    @tvar[13] = 85.0
    @tvar[14] = 90.0
    #
    # age specific competing hazards (h2) - BCPT model or STAR model
    # SEER mortality 1985:87, excluding death from breast cancer - white, African American)
    # US   mortality 1990:96, excluding death from breast cancer -     hispanic)
    # ages [20:25), [25:30), [30:35) .... [70:74), [75:80), [80:85), [85:90)
    #
    @rmu2[0][0] = 49.3 * 0.00001 # [20:25) race=white,other  1/12
    @rmu2[1][0] = 53.1 * 0.00001 # [25:30) race=white,other  BCPT
    @rmu2[2][0] = 62.5 * 0.00001 # [30:35) race=white,other
    @rmu2[3][0] = 82.5 * 0.00001 # [35:40) race=white,other
    @rmu2[4][0] = 130.7 * 0.00001 # [40:45) race=white,other
    @rmu2[5][0] = 218.1 * 0.00001 # [45:50) race=white,other
    @rmu2[6][0] = 365.5 * 0.00001 # [50:55) race=white,other
    @rmu2[7][0] = 585.2 * 0.00001 # [55:60) race=white,other
    @rmu2[8][0] = 943.9 * 0.00001 # [60:65) race=white,other
    @rmu2[9][0] = 1502.8 * 0.00001 # [65:70) race=white,other
    @rmu2[10][0] = 2383.9 * 0.00001 # [70:75) race=white,other
    @rmu2[11][0] = 3883.2 * 0.00001 # [75:80) race=white,other
    @rmu2[12][0] = 6682.8 * 0.00001 # [80:85) race=white,other
    @rmu2[13][0] = 14490.8 * 0.00001 # [85:90) race=white,other
    # 11/29/2007 SRamaiah - updated age specific competing hazards (h2)
    # with new values from NCHS 1996-00 data for African American Women
    #
    # Updated array  rmu2[*, 1] with following new values for African American Women
    #
    @rmu2[0][1] = 0.00074354 # [20,25) race=African American    11/28/2007
    @rmu2[1][1] = 0.00101698 # [24,30) race=African American
    @rmu2[2][1] = 0.00145937 # [30,35) race=African American
    @rmu2[3][1] = 0.00215933 # [34,40) race=African American
    @rmu2[4][1] = 0.00315077 # [40,45) race=African American
    @rmu2[5][1] = 0.00448779 # [44,50) race=African American
    @rmu2[6][1] = 0.00632281 # [50,55) race=African American
    @rmu2[7][1] = 0.00963037 # [54,60) race=African American
    @rmu2[8][1] = 0.01471818 # [60,65) race=African American
    @rmu2[9][1] = 0.02116304 # [64,70) race=African American
    @rmu2[10][1] = 0.03266035 # [70,75) race=African American
    @rmu2[11][1] = 0.04564087 # [74,80) race=African American
    @rmu2[12][1] = 0.06835185 # [80,84) race=African American
    @rmu2[13][1] = 0.13271262 # [84,90) race=African American
    # -- old values --
    # rmu2[0, 1] = 73.2 * 0.00001;        // [20:25) race=African American     1/12/99
    # rmu2[1, 1] = 100.5 * 0.00001;        // [25:30) race=African American        BCPT
    # rmu2[2, 1] = 143.4 * 0.00001;        // [30:35) race=African American
    # rmu2[3, 1] = 185.4 * 0.00001;        // [35:40) race=African American
    # rmu2[4, 1] = 270.9 * 0.00001;        // [40:45) race=African American
    # rmu2[5, 1] = 402.4 * 0.00001;        // [45:50) race=African American
    # rmu2[6, 1] = 646.6 * 0.00001;        // [50:55) race=African American
    # rmu2[7, 1] = 956.4 * 0.00001;        // [55:60) race=African American
    # rmu2[8, 1] = 1496.8 * 0.00001;        // [60:65) race=African American
    # rmu2[9, 1] = 2069.2 * 0.00001;        // [65:70) race=African American
    # rmu2[10, 1] = 3128.3 * 0.00001;        // [70:75) race=African American
    # rmu2[11, 1] = 4533.9 * 0.00001;        // [75:80) race=African American
    # rmu2[12, 1] = 7532.6 * 0.00001;        // [80:85) race=African American
    # rmu2[13, 1] = 11716.6 * 0.00001;        // [85:90) race=African American
    #
    @rmu2[0][2] = 43.7 * 0.00001 # [20:25) race=hispanic  5/12/00
    @rmu2[1][2] = 53.3 * 0.00001 # [25:30) race=hispanic     STAR
    @rmu2[2][2] = 70.0 * 0.00001 # [30:35) race=hispanic
    @rmu2[3][2] = 89.7 * 0.00001 # [35:40) race=hispanic
    @rmu2[4][2] = 116.3 * 0.00001 # [40:45) race=hispanic
    @rmu2[5][2] = 170.2 * 0.00001 # [45:50) race=hispanic
    @rmu2[6][2] = 264.6 * 0.00001 # [50:55) race=hispanic
    @rmu2[7][2] = 421.6 * 0.00001 # [55:60) race=hispanic
    @rmu2[8][2] = 696.0 * 0.00001 # [60:65) race=hispanic
    @rmu2[9][2] = 1086.7 * 0.00001 # [65:70) race=hispanic
    @rmu2[10][2] = 1685.8 * 0.00001 # [70:75) race=hispanic
    @rmu2[11][2] = 2515.6 * 0.00001 # [75:80) race=hispanic
    @rmu2[12][2] = 4186.6 * 0.00001 # [80:85) race=hispanic
    @rmu2[13][2] = 8947.6 * 0.00001 # [85:90) race=hispanic
    #
    # age specific competing hazards (h2) for "average woman"
    # (NCHS mortality 1992:95, excluding death from breast cancer - white, African American)
    # (US   mortality 1990:95, excluding death from breast cancer -     hispanic)
    # ages [20:25), [25:30), [30:35) .... [70:74), [75:80), [80:85), [85:90)
    #
    @rmu2[0][3] = 44.12 * 0.00001 # [20,25) race=white,other 11/21
    @rmu2[1][3] = 52.54 * 0.00001 # [24,30) race=white,other
    @rmu2[2][3] = 67.46 * 0.00001 # [30,35) race=white,other
    @rmu2[3][3] = 90.92 * 0.00001 # [34,40) race=white,other
    @rmu2[4][3] = 125.34 * 0.00001 # [40,45) race=white,other
    @rmu2[5][3] = 195.70 * 0.00001 # [44,50) race=white,other
    @rmu2[6][3] = 329.84 * 0.00001 # [50,55) race=white,other
    @rmu2[7][3] = 546.22 * 0.00001 # [54,60) race=white,other
    @rmu2[8][3] = 910.35 * 0.00001 # [60,65) race=white,other
    @rmu2[9][3] = 1418.54 * 0.00001 # [64,70) race=white,other
    @rmu2[10][3] = 2259.35 * 0.00001 # [70,75) race=white,other
    @rmu2[11][3] = 3611.46 * 0.00001 # [74,80) race=white,other
    @rmu2[12][3] = 6136.26 * 0.00001 # [80,84) race=white,other
    @rmu2[13][3] = 14206.63 * 0.00001 # [84,90) race=white,other
    # 11/29/2007 SRamaiah - updated age specific competing hazards (h2)
    # with new values from NCHS 1996-00 data for African American Women
    #
    # Updated array rmu2[*, 4] with following new values for African American Women
    #
    @rmu2[0][4] = 0.00074354 # [20,25) race=African American    11/28/07
    @rmu2[1][4] = 0.00101698 # [24,30) race=African American
    @rmu2[2][4] = 0.00145937 # [30,35) race=African American
    @rmu2[3][4] = 0.00215933 # [34,40) race=African American
    @rmu2[4][4] = 0.00315077 # [40,45) race=African American
    @rmu2[5][4] = 0.00448779 # [44,50) race=African American
    @rmu2[6][4] = 0.00632281 # [50,55) race=African American
    @rmu2[7][4] = 0.00963037 # [54,60) race=African American
    @rmu2[8][4] = 0.01471818 # [60,65) race=African American
    @rmu2[9][4] = 0.02116304 # [64,70) race=African American
    @rmu2[10][4] = 0.03266035 # [70,75) race=African American
    @rmu2[11][4] = 0.04564087 # [74,80) race=African American
    @rmu2[12][4] = 0.06835185 # [80,84) race=African American
    @rmu2[13][4] = 0.13271262 # [84,90) race=African American
    # -- old values
    # rmu2[0, 4] = 86.05 * 0.00001;         // [20,25) race=African American    11/21/99
    # rmu2[1, 4] = 129.21 * 0.00001;         // [24,30) race=African American
    # rmu2[2, 4] = 183.85 * 0.00001;         // [30,35) race=African American
    # rmu2[3, 4] = 256.14 * 0.00001;         // [34,40) race=African American
    # rmu2[4, 4] = 342.62 * 0.00001;         // [40,45) race=African American
    # rmu2[5, 4] = 469.96 * 0.00001;         // [44,50) race=African American
    # rmu2[6, 4] = 678.98 * 0.00001;         // [50,55) race=African American
    # rmu2[7, 4] = 1028.23 * 0.00001;         // [54,60) race=African American
    # rmu2[8, 4] = 1530.83 * 0.00001;         // [60,65) race=African American
    # rmu2[9, 4] = 2199.72 * 0.00001;         // [64,70) race=African American
    # rmu2[10, 4] = 3335.91 * 0.00001;         // [70,75) race=African American
    # rmu2[11, 4] = 4571.50 * 0.00001;         // [74,80) race=African American
    # rmu2[12, 4] = 7197.04 * 0.00001;         // [80,84) race=African American
    # rmu2[13, 4] = 12978.86 * 0.00001;         // [84,90) race=African American
    # ---
    @rmu2[0][5] = 43.7 * 0.00001 # [20:25) race=hispanic  5/12/00
    @rmu2[1][5] = 53.3 * 0.00001 # [25:30) race=hispanic
    @rmu2[2][5] = 70.0 * 0.00001 # [30:35) race=hispanic
    @rmu2[3][5] = 89.7 * 0.00001 # [35:40) race=hispanic
    @rmu2[4][5] = 116.3 * 0.00001 # [40:45) race=hispanic
    @rmu2[5][5] = 170.2 * 0.00001 # [45:50) race=hispanic
    @rmu2[6][5] = 264.6 * 0.00001 # [50:55) race=hispanic
    @rmu2[7][5] = 421.6 * 0.00001 # [55:60) race=hispanic
    @rmu2[8][5] = 696.0 * 0.00001 # [60:65) race=hispanic
    @rmu2[9][5] = 1086.7 * 0.00001 # [65:70) race=hispanic
    @rmu2[10][5] = 1685.8 * 0.00001 # [70:75) race=hispanic
    @rmu2[11][5] = 2515.6 * 0.00001 # [75:80) race=hispanic
    @rmu2[12][5] = 4186.6 * 0.00001 # [80:85) race=hispanic
    @rmu2[13][5] = 8947.6 * 0.00001 # [85:90) race=hispanic
    #
    # age specific breast cancer composite incidence (h1*)
    # (SEER incidence 1983:87 - white)                                      BCPT
    # (SEER incidence 1994-98 - African American)                                      SEER11
    # (SEER incidence 1990:96 -     hispanic)                               STAR
    # ages [20:25), [25:30), [30:35) .... [70:74), [75:80), [80:85), [85:90)
    #
    @rlan2[0][0] = 1.0 * 0.00001 # [20:25) race=white,other  1/12
    @rlan2[1][0] = 7.6 * 0.00001 # [25:30) race=white,other  BCPT
    @rlan2[2][0] = 26.6 * 0.00001 # [30:35) race=white,other
    @rlan2[3][0] = 66.1 * 0.00001 # [35:40) race=white,other
    @rlan2[4][0] = 126.5 * 0.00001 # [40:45) race=white,other
    @rlan2[5][0] = 186.6 * 0.00001 # [45:50) race=white,other
    @rlan2[6][0] = 221.1 * 0.00001 # [50:55) race=white,other
    @rlan2[7][0] = 272.1 * 0.00001 # [55:60) race=white,other
    @rlan2[8][0] = 334.8 * 0.00001 # [60:65) race=white,other
    @rlan2[9][0] = 392.3 * 0.00001 # [65:70) race=white,other
    @rlan2[10][0] = 417.8 * 0.00001 # [70:75) race=white,other
    @rlan2[11][0] = 443.9 * 0.00001 # [75:80) race=white,other
    @rlan2[12][0] = 442.1 * 0.00001 # [80:85) race=white,other
    @rlan2[13][0] = 410.9 * 0.00001 # [85:90) race=white,other
    # 11/29/2007 SRamaiah - updated age specific breast cancer composite incidence (h1*)
    # with new values from 1994-98SEER11 data for African American Women
    #
    # Updated array rlan2[*, 1] with following new values for African American Women
    #
    @rlan2[0][1] = 0.00002696 # [20:25) race=African American    11/29/2007
    @rlan2[1][1] = 0.00011295 # [25:30) race=African American
    @rlan2[2][1] = 0.00031094 # [30:35) race=African American
    @rlan2[3][1] = 0.00067639 # [35:40) race=African American
    @rlan2[4][1] = 0.00119444 # [40:45) race=African American
    @rlan2[5][1] = 0.00187394 # [45:50) race=African American
    @rlan2[6][1] = 0.00241504 # [50:55) race=African American
    @rlan2[7][1] = 0.00291112 # [55:60) race=African American
    @rlan2[8][1] = 0.00310127 # [60:65) race=African American
    @rlan2[9][1] = 0.00366560 # [65:70) race=African American
    @rlan2[10][1] = 0.00393132 # [70:75) race=African American
    @rlan2[11][1] = 0.00408951 # [75:80) race=African American
    @rlan2[12][1] = 0.00396793 # [80:85) race=African American
    @rlan2[13][1] = 0.00363712 # [85:90) race=African American
    # -- old values ---
    # rlan2[0, 1] = 1.5 * 0.00001;        // [20:25) race=African American     1/12/99
    # rlan2[1, 1] = 12.2 * 0.00001;        // [25:30) race=African American        BCPT
    # rlan2[2, 1] = 36.5 * 0.00001;        // [30:35) race=African American
    # rlan2[3, 1] = 79.6 * 0.00001;        // [35:40) race=African American
    # rlan2[4, 1] = 137.7 * 0.00001;        // [40:45) race=African American
    # rlan2[5, 1] = 165.4 * 0.00001;        // [45:50) race=African American
    # rlan2[6, 1] = 177.9 * 0.00001;        // [50:55) race=African American
    # rlan2[7, 1] = 224.3 * 0.00001;        // [55:60) race=African American
    # rlan2[8, 1] = 275.0 * 0.00001;        // [60:65) race=African American
    # rlan2[9, 1] = 280.3 * 0.00001;        // [65:70) race=African American
    # rlan2[10, 1] = 309.9 * 0.00001;        // [70:75) race=African American
    # rlan2[11, 1] = 360.2 * 0.00001;        // [75:80) race=African American
    # rlan2[12, 1] = 414.2 * 0.00001;        // [80:85) race=African American
    # rlan2[13, 1] = 345.2 * 0.00001;        // [85:90) race=African American
    #
    #
    @rlan2[0][2] = 2.00 * 0.00001 # [20:25) race=hispanic  5/12/00
    @rlan2[1][2] = 7.10 * 0.00001 # [25:30) race=hispanic     STAR
    @rlan2[2][2] = 19.70 * 0.00001 # [30:35) race=hispanic
    @rlan2[3][2] = 43.80 * 0.00001 # [35:40) race=hispanic
    @rlan2[4][2] = 81.10 * 0.00001 # [40:45) race=hispanic
    @rlan2[5][2] = 130.70 * 0.00001 # [45:50) race=hispanic
    @rlan2[6][2] = 157.40 * 0.00001 # [50:55) race=hispanic
    @rlan2[7][2] = 185.70 * 0.00001 # [55:60) race=hispanic
    @rlan2[8][2] = 215.10 * 0.00001 # [60:65) race=hispanic
    @rlan2[9][2] = 251.20 * 0.00001 # [65:70) race=hispanic
    @rlan2[10][2] = 284.60 * 0.00001 # [70:75) race=hispanic
    @rlan2[11][2] = 275.70 * 0.00001 # [75:80) race=hispanic
    @rlan2[12][2] = 252.30 * 0.00001 # [80:85) race=hispanic
    @rlan2[13][2] = 203.90 * 0.00001 # [85:90) race=hispanic
    #
    # age specific breast cancer composite incidence (h1*)-"average woman"
    # (SEER incidence 1992:96 - white, African American)
    # (SEER incidence 1990:96 -     hispanic)
    # ages [20:25), [25:30), [30:35) .... [70:74), [75:80), [80:85), [85:90)
    #
    @rlan2[0][3] = 1.22 * 0.00001 # [20:25) race=white,other 11/21
    @rlan2[1][3] = 7.41 * 0.00001 # [25:30) race=white,other
    @rlan2[2][3] = 22.97 * 0.00001 # [30:35) race=white,other
    @rlan2[3][3] = 56.49 * 0.00001 # [35:40) race=white,other
    @rlan2[4][3] = 116.45 * 0.00001 # [40:45) race=white,other
    @rlan2[5][3] = 195.25 * 0.00001 # [45:50) race=white,other
    @rlan2[6][3] = 261.54 * 0.00001 # [50:55) race=white,other
    @rlan2[7][3] = 302.79 * 0.00001 # [55:60) race=white,other
    @rlan2[8][3] = 367.57 * 0.00001 # [60:65) race=white,other
    @rlan2[9][3] = 420.29 * 0.00001 # [65:70) race=white,other
    @rlan2[10][3] = 473.08 * 0.00001 # [70:75) race=white,other
    @rlan2[11][3] = 494.25 * 0.00001 # [75:80) race=white,other
    @rlan2[12][3] = 479.76 * 0.00001 # [80:85) race=white,other
    @rlan2[13][3] = 401.06 * 0.00001 # [85:90) race=white,other
    # 11/29/2007 SRamaiah - updated age specific breast cancer composite incidence (h1*)
    # with new values from 1994-98SEER11 data for African American Women
    #
    # Updated array rlan2[*, 4] with following new values for African American Women
    #
    @rlan2[0][4] = 0.00002696 # [20:25) race=African American    11/29/2007
    @rlan2[1][4] = 0.00011295 # [25:30) race=African American
    @rlan2[2][4] = 0.00031094 # [30:35) race=African American
    @rlan2[3][4] = 0.00067639 # [35:40) race=African American
    @rlan2[4][4] = 0.00119444 # [40:45) race=African American
    @rlan2[5][4] = 0.00187394 # [45:50) race=African American
    @rlan2[6][4] = 0.00241504 # [50:55) race=African American
    @rlan2[7][4] = 0.00291112 # [55:60) race=African American
    @rlan2[8][4] = 0.00310127 # [60:65) race=African American
    @rlan2[9][4] = 0.00366560 # [65:70) race=African American
    @rlan2[10][4] = 0.00393132 # [70:75) race=African American
    @rlan2[11][4] = 0.00408951 # [75:80) race=African American
    @rlan2[12][4] = 0.00396793 # [80:85) race=African American
    @rlan2[13][4] = 0.00363712 # [85:90) race=African American
    # -- old values ---
    # rlan2[0, 4] = 2.65 * 0.00001;       // [20:25) race=African American    11/21/99
    # rlan2[1, 4] = 10.90 * 0.00001;       // [25:30) race=African American
    # rlan2[2, 4] = 32.31 * 0.00001;       // [30:35) race=African American
    # rlan2[3, 4] = 63.15 * 0.00001;       // [35:40) race=African American
    # rlan2[4, 4] = 120.46 * 0.00001;       // [40:45) race=African American
    # rlan2[5, 4] = 191.32 * 0.00001;       // [45:50) race=African American
    # rlan2[6, 4] = 234.05 * 0.00001;       // [50:55) race=African American
    # rlan2[7, 4] = 281.26 * 0.00001;       // [55:60) race=African American
    # rlan2[8, 4] = 303.45 * 0.00001;       // [60:65) race=African American
    # rlan2[9, 4] = 340.47 * 0.00001;       // [65:70) race=African American
    # rlan2[10, 4] = 377.43 * 0.00001;       // [70:75) race=African American
    # rlan2[11, 4] = 394.48 * 0.00001;       // [75:80) race=African American
    # rlan2[12, 4] = 378.97 * 0.00001;       // [80:85) race=African American
    # rlan2[13, 4] = 349.11 * 0.00001;       // [85:90) race=African American
    #
    @rlan2[0][5] = 2.00 * 0.00001 # [20:25) race=hispanic  5/12/00
    @rlan2[1][5] = 7.10 * 0.00001 # [25:30) race=hispanic
    @rlan2[2][5] = 19.70 * 0.00001 # [30:35) race=hispanic
    @rlan2[3][5] = 43.80 * 0.00001 # [35:40) race=hispanic
    @rlan2[4][5] = 81.10 * 0.00001 # [40:45) race=hispanic
    @rlan2[5][5] = 130.70 * 0.00001 # [45:50) race=hispanic
    @rlan2[6][5] = 157.40 * 0.00001 # [50:55) race=hispanic
    @rlan2[7][5] = 185.70 * 0.00001 # [55:60) race=hispanic
    @rlan2[8][5] = 215.10 * 0.00001 # [60:65) race=hispanic
    @rlan2[9][5] = 251.20 * 0.00001 # [65:70) race=hispanic
    @rlan2[10][5] = 284.60 * 0.00001 # [70:75) race=hispanic
    @rlan2[11][5] = 275.70 * 0.00001 # [75:80) race=hispanic
    @rlan2[12][5] = 252.30 * 0.00001 # [80:85) race=hispanic
    @rlan2[13][5] = 203.90 * 0.00001 # [85:90) race=hispanic
    #11/29/2007 replaced with two dimensional array
    #
    # bet[0] = -.74948246; // intercept                         1/1
    # bet[1] = .010808072; // age >=50 indicator
    # bet[2] = .0940103059; // age menarchy
    # bet[3] = .5292641686; // # of breast biopsy
    # bet[4] = .2186262218; // age 1st live birth
    # bet[5] = .9583027845; // # 1st degree relatives with breast ca
    # bet[6] = -.288042483; // # breast biopsy * age >=50 indicator
    # bet[7] = -.1908113865; // ** conversion factors (1-attributable risk) used in BCPT model
    #
    # White & Other women logistic regression coefficients - GAIL model (BCDDP)
    @bet2[0][0] = -0.7494824600 # intercept            1/12/99 & 11/13/07
    @bet2[1][0] = 0.0108080720 # age >= 50 indicator
    @bet2[2][0] = 0.0940103059 # age menarchy
    @bet2[3][0] = 0.5292641686 # # of breast biopsy
    @bet2[4][0] = 0.2186262218 # age 1st live birth
    @bet2[5][0] = 0.9583027845 # # 1st degree relatives with breast ca
    @bet2[6][0] = -0.2880424830 # # breast biopsy * age >=50 indicator
    @bet2[7][0] = -0.1908113865 # age 1st live birth * # 1st degree rel
    # African American women  logistic regression coefficients - CARE model
    @bet2[0][1] = -0.3457169653 # intercept                      11/13/07
    @bet2[1][1] = 0.0334703319 # age >= 50 indicator set \E1 to 0 in PGM
    @bet2[2][1] = 0.2672530336 # age menarchy
    @bet2[3][1] = 0.1822121131 # # of breast biopsy
    @bet2[4][1] = 0.0000000000 # age 1st live birth
    @bet2[5][1] = 0.4757242578 # # 1st degree relatives with breast ca
    @bet2[6][1] = -0.1119411682 # # breast biopsy * age >=50 indicator
    @bet2[7][1] = 0.0000000000 # age 1st live birth * # 1st degree rel
    # Hispanic women   logistic regression coefficients - GAIL model (BCDDP)
    @bet2[0][2] = -0.7494824600 # intercept            1/12/99 & 11/13/07
    @bet2[1][2] = 0.0108080720 # age >= 50 indicator
    @bet2[2][2] = 0.0940103059 # age menarchy
    @bet2[3][2] = 0.5292641686 # # of breast biopsy
    @bet2[4][2] = 0.2186262218 # age 1st live birth
    @bet2[5][2] = 0.9583027845 # # 1st degree relatives with breast ca
    @bet2[6][2] = -0.2880424830 # # breast biopsy * age >=50 indicator
    @bet2[7][2] = -0.1908113865 # age 1st live birth * # 1st degree rel
    #American-Asian Beta
    i = 6
    while i <= 11
      @bet2[0][i] = 0.00000000000000 #  intercept
      @bet2[1][i] = 0.00000000000000 #  age >= 50 indicator
      @bet2[2][i] = 0.07499257592975 #age menarchy
      @bet2[3][i] = 0.55263612260619 #   # of breast biopsy
      @bet2[4][i] = 0.27638268294593 #  age 1st live birth
      @bet2[5][i] = 0.79185633720481 #   # 1st degree relatives with breast ca
      @bet2[6][i] = 0.00000000000000 #  # breast biopsy * age >=50 indicator
      @bet2[7][i] = 0.00000000000000
      i += 1
    end #   age 1st live birth * # 1st degree rel
    # age 1st live birth * # 1st degree rel
    # conversion factors (1-attributable risk) used in BCPT model
    @rf2[0][0] = 0.5788413 # age < 50, race=white,other        1/12/99
    @rf2[1][0] = 0.5788413 # age >=50, race=white,other
    # 11/27/2007 SRamaiah.
    # * Based on Journal(JNCI djm223 LM) published on Dec 05, 2007 by Gail and other scientists,
    # * The new values are being used for african american woman
    # * as there were some major descrenpancies between CARE model and GAIL Model
    #
    # -- Old values
    # rf2[0, 1] = 0.4145300;         // age < 50, race=African American      1/12/99
    # rf2[1, 1] = 0.4227500;         // age >=50, race=African American
    #
    # rf2[0, 1] = 0.7295;         // age < 50, race=African American         11/27/2007 based on journal value
    # rf2[1, 1] = 0.7440;         // age >=50, race=African American
    #
    @rf2[0][1] = 0.72949880 # age < 50, race=African American     12/19/2007 based on david pee's input
    @rf2[1][1] = 0.74397137 # age >=50, race=African American
    @rf2[0][2] = 0.5788413 # age < 50, race=hispanic   5/12/2000
    @rf2[1][2] = 0.5788413 # age >=50, race=hispanic
    # conversion factors (1-attributable risk) used for "average woman"
    @rf2[0][3] = 1.0 # age < 50, race=white avg woman      11/21
    @rf2[1][3] = 1.0 # age >=50, race=white avg woman
    @rf2[0][4] = 1.0 # age < 50, race=African American avg woman      11/21
    @rf2[1][4] = 1.0 # age >=50, race=African American avg woman
    @rf2[0][5] = 1.0 # age < 50, race=hispanic avg woman    5/12
    @rf2[1][5] = 1.0 # age >=50, race=hispanic avg woman
    #American-Asian conversion factor
    i = 6
    while i <= 11
      @rf2[0][i] = 0.47519806426735 # age < 50, avg woman
      @rf2[1][i] = 0.50316401683903
      i += 1
    end # age >=50, avg woman
    @rf2[0][12] = 1.0 # age < 50, race=hispanic avg woman    5/12
    @rf2[1][12] = 1.0 # age >=50, race=hispanic avg woman
    #*** SEER18 incidence 1998:02 - chinese  Jan052010;
    @rlan2[0][6] = 0.000004059636
    @rlan2[1][6] = 0.000045944465
    @rlan2[2][6] = 0.000188279352
    @rlan2[3][6] = 0.000492930493
    @rlan2[4][6] = 0.000913603501
    @rlan2[5][6] = 0.001471537353
    @rlan2[6][6] = 0.001421275482
    @rlan2[7][6] = 0.001970946494
    @rlan2[8][6] = 0.001674745804
    @rlan2[9][6] = 0.001821581075
    @rlan2[10][6] = 0.001834477198
    @rlan2[11][6] = 0.001919911972
    @rlan2[12][6] = 0.002233371071
    @rlan2[13][6] = 0.002247315779
    #*** NCHS mortality 1998:02,    chinese  Jan052010;
    @rmu2[0][6] = 0.000210649076
    @rmu2[1][6] = 0.000192644865
    @rmu2[2][6] = 0.000244435215
    @rmu2[3][6] = 0.000317895949
    @rmu2[4][6] = 0.000473261994
    @rmu2[5][6] = 0.000800271380
    @rmu2[6][6] = 0.001217480226
    @rmu2[7][6] = 0.002099836508
    @rmu2[8][6] = 0.003436889186
    @rmu2[9][6] = 0.006097405623
    @rmu2[10][6] = 0.010664526765
    @rmu2[11][6] = 0.020148678452
    @rmu2[12][6] = 0.037990796590
    @rmu2[13][6] = 0.098333900733
    #*** SEER18 incidence 1998:02 - japanese  Jan052010;
    @rlan2[0][7] = 0.000000000001
    @rlan2[1][7] = 0.000099483924
    @rlan2[2][7] = 0.000287041681
    @rlan2[3][7] = 0.000545285759
    @rlan2[4][7] = 0.001152211095
    @rlan2[5][7] = 0.001859245108
    @rlan2[6][7] = 0.002606291272
    @rlan2[7][7] = 0.003221751682
    @rlan2[8][7] = 0.004006961859
    @rlan2[9][7] = 0.003521715275
    @rlan2[10][7] = 0.003593038294
    @rlan2[11][7] = 0.003589303081
    @rlan2[12][7] = 0.003538507159
    @rlan2[13][7] = 0.002051572909
    #*** NCHS mortality 1998:02,    japanese  Jan052010;
    @rmu2[0][7] = 0.000173593803
    @rmu2[1][7] = 0.000295805882
    @rmu2[2][7] = 0.000228322534
    @rmu2[3][7] = 0.000363242389
    @rmu2[4][7] = 0.000590633044
    @rmu2[5][7] = 0.001086079485
    @rmu2[6][7] = 0.001859999966
    @rmu2[7][7] = 0.003216600974
    @rmu2[8][7] = 0.004719402141
    @rmu2[9][7] = 0.008535331402
    @rmu2[10][7] = 0.012433511681
    @rmu2[11][7] = 0.020230197885
    @rmu2[12][7] = 0.037725498348
    @rmu2[13][7] = 0.106149118663
    #*** SEER18 incidence 1998:02 - filipino  Jan052010;
    @rlan2[0][8] = 0.000007500161
    @rlan2[1][8] = 0.000081073945
    @rlan2[2][8] = 0.000227492565
    @rlan2[3][8] = 0.000549786433
    @rlan2[4][8] = 0.001129400541
    @rlan2[5][8] = 0.001813873795
    @rlan2[6][8] = 0.002223665639
    @rlan2[7][8] = 0.002680309266
    @rlan2[8][8] = 0.002891219230
    @rlan2[9][8] = 0.002534421279
    @rlan2[10][8] = 0.002457159409
    @rlan2[11][8] = 0.002286616920
    @rlan2[12][8] = 0.001814802825
    @rlan2[13][8] = 0.001750879130
    #*** NCHS mortality 1998:02,    filipino  Jan052010;
    @rmu2[0][8] = 0.000229120979
    @rmu2[1][8] = 0.000262988494
    @rmu2[2][8] = 0.000314844090
    @rmu2[3][8] = 0.000394471908
    @rmu2[4][8] = 0.000647622610
    @rmu2[5][8] = 0.001170202327
    @rmu2[6][8] = 0.001809380379
    @rmu2[7][8] = 0.002614170568
    @rmu2[8][8] = 0.004483330681
    @rmu2[9][8] = 0.007393665092
    @rmu2[10][8] = 0.012233059675
    @rmu2[11][8] = 0.021127058106
    @rmu2[12][8] = 0.037936954809
    @rmu2[13][8] = 0.085138518334
    #*** SEER18 incidence 1998:02 - hawaiian  Jan052010;
    @rlan2[0][9] = 0.000045080582
    @rlan2[1][9] = 0.000098570724
    @rlan2[2][9] = 0.000339970860
    @rlan2[3][9] = 0.000852591429
    @rlan2[4][9] = 0.001668562761
    @rlan2[5][9] = 0.002552703284
    @rlan2[6][9] = 0.003321774046
    @rlan2[7][9] = 0.005373001776
    @rlan2[8][9] = 0.005237808549
    @rlan2[9][9] = 0.005581732512
    @rlan2[10][9] = 0.005677419355
    @rlan2[11][9] = 0.006513409962
    @rlan2[12][9] = 0.003889457523
    @rlan2[13][9] = 0.002949061662
    #*** NCHS mortality 1998:02,    hawaiian  Jan052010;
    @rmu2[0][9] = 0.000563507269
    @rmu2[1][9] = 0.000369640217
    @rmu2[2][9] = 0.001019912579
    @rmu2[3][9] = 0.001234013911
    @rmu2[4][9] = 0.002098344078
    @rmu2[5][9] = 0.002982934175
    @rmu2[6][9] = 0.005402445702
    @rmu2[7][9] = 0.009591474245
    @rmu2[8][9] = 0.016315472607
    @rmu2[9][9] = 0.020152229069
    @rmu2[10][9] = 0.027354838710
    @rmu2[11][9] = 0.050446998723
    @rmu2[12][9] = 0.072262026612
    @rmu2[13][9] = 0.145844504021
    #*** SEER18 incidence 1998:02 - other pacific islander  Jan052010;
    @rlan2[0][10] = 0.000000000001
    @rlan2[1][10] = 0.000071525212
    @rlan2[2][10] = 0.000288799028
    @rlan2[3][10] = 0.000602250698
    @rlan2[4][10] = 0.000755579402
    @rlan2[5][10] = 0.000766406354
    @rlan2[6][10] = 0.001893124938
    @rlan2[7][10] = 0.002365580107
    @rlan2[8][10] = 0.002843933070
    @rlan2[9][10] = 0.002920921732
    @rlan2[10][10] = 0.002330395655
    @rlan2[11][10] = 0.002036291235
    @rlan2[12][10] = 0.001482683983
    @rlan2[13][10] = 0.001012248203
    #*** NCHS mortality 1998:02,    other pacific islander  Jan052010;
    @rmu2[0][10] = 0.000465500812
    @rmu2[1][10] = 0.000600466920
    @rmu2[2][10] = 0.000851057138
    @rmu2[3][10] = 0.001478265376
    @rmu2[4][10] = 0.001931486788
    @rmu2[5][10] = 0.003866623959
    @rmu2[6][10] = 0.004924932309
    @rmu2[7][10] = 0.008177071806
    @rmu2[8][10] = 0.008638202890
    @rmu2[9][10] = 0.018974658371
    @rmu2[10][10] = 0.029257567105
    @rmu2[11][10] = 0.038408980974
    @rmu2[12][10] = 0.052869579345
    @rmu2[13][10] = 0.074745721133
    #*** SEER18 incidence 1998:02 - other asian  Jan052010;
    @rlan2[0][11] = 0.000012355409
    @rlan2[1][11] = 0.000059526456
    @rlan2[2][11] = 0.000184320831
    @rlan2[3][11] = 0.000454677273
    @rlan2[4][11] = 0.000791265338
    @rlan2[5][11] = 0.001048462801
    @rlan2[6][11] = 0.001372467817
    @rlan2[7][11] = 0.001495473711
    @rlan2[8][11] = 0.001646746198
    @rlan2[9][11] = 0.001478363563
    @rlan2[10][11] = 0.001216010125
    @rlan2[11][11] = 0.001067663700
    @rlan2[12][11] = 0.001376104012
    @rlan2[13][11] = 0.000661576644
    #*** NCHS mortality 1998:02,    other asian Jan052010;
    @rmu2[0][11] = 0.000212632332
    @rmu2[1][11] = 0.000242170741
    @rmu2[2][11] = 0.000301552711
    @rmu2[3][11] = 0.000369053354
    @rmu2[4][11] = 0.000543002943
    @rmu2[5][11] = 0.000893862331
    @rmu2[6][11] = 0.001515172239
    @rmu2[7][11] = 0.002574669551
    @rmu2[8][11] = 0.004324370426
    @rmu2[9][11] = 0.007419621918
    @rmu2[10][11] = 0.013251765130
    @rmu2[11][11] = 0.022291427490
    @rmu2[12][11] = 0.041746550635
    @rmu2[13][11] = 0.087485802065
  end

  def calculate_absolute_risk(current_age, projection_age, age_indicator, number_of_biopsy, menarche_age, first_live_birth_age, first_deg_relatives, ever_had_biopsy, ihyp, rhyp, irace)
    return self.calculate_risk(1, current_age, projection_age, age_indicator, number_of_biopsy, menarche_age, first_live_birth_age, ever_had_biopsy, first_deg_relatives, ihyp, rhyp, irace)
  end

  def calculate_average_risk(current_age, projection_age, age_indicator, number_of_biopsy, menarche_age, first_live_birth_age, first_deg_relatives, ever_had_biopsy, ihyp, rhyp, irace)
    return self.calculate_risk(2, current_age, projection_age, age_indicator, number_of_biopsy, menarche_age, first_live_birth_age, ever_had_biopsy, first_deg_relatives, ihyp, rhyp, irace)
  end

  def calculate_risk(riskindex, current_age, projection_age, age_indicator, number_of_biopsy, menarche_age, first_live_birth_age, ever_had_biopsy, first_deg_relatives, ihyp, rhyp, irace)

    # AgeIndicator: age ge 50 ind
    # 0=[20, 50)
    # 1=[50, 85)
    # MenarcheAge: age menarchy
    # 0=[14, 39] U 99 (unknown)
    # 1=[12, 14)
    # 2=[ 7, 12)
    # NumberOfBiopsy: # biopsy
    # 0=0 or (99 and ever had biopsy=99
    # 1=1 or (99 and ever had biopsy=1 y
    # 2=[ 2, 30]
    # FirstLiveBirthAge: age 1st live
    # 0=<20, 99 (unknown)
    # 1=[20, 25)
    # 2=[25, 30) U 0
    # 3=[30, 55]
    # FirstDegRelatives: 1st degree rel
    # 0=0, 99 (unknown)
    # 1=1
    # 2=[2, 31]

    #  RiskIndex           [1 Abs, 2 Avg]
    #, CurrentAge		    //[t1] edad actual ( tiene que ser mayor a 35)
    #, ProjectionAge	    //[t2]
    #, AgeIndicator	    //[i0]
    #, NumberOfBiopsy	    //[i2] cant de biopsias de mamas 1, 2(2 had_biopsy mas)
    #, MenarcheAge		    //[i1] edad de primera menstruacion
    #, FirstLiveBirthAge   //[i3] 0 , 15 (<20),22(20-24), 27(25-29),30(>=30)
    #, EverHadBiopsy	    //[iever] 0 no, 1 yes, 99 unknown
    #, HyperPlasia		    //[ihyp] 0 no, 1 yes, 99 unknown
    #, FirstDegRelatives   //[i4] 0, 1 or 2(2 or more)
    #, RHyperPlasia	    //[rhyp] 0 no, 1 yes, 99 unknown
    #, Race			    //[race] 1-white 3-hispanic 6-unknown
    retval = 0.0
    # Local variables
    abss = 0.0
    r8i_tox2 = Array.new(216) {Array.new(9)}
    #double[] r8i_tox2 = new double[1944]; //[216,9];
    n = 216 # ** age categories boundaries
    r = 0.0
    #HACK
    ni = 0
    ns = 0
    ti = (current_age)
    ts = (projection_age)
    # 11/29/2007 SR: setting BETA to race specific lnRR
    i = 0
    while i < 8
      @bet[i] = @bet2[i][irace - 1]
      i += 1
    end #index starts from 0 hence irace-1
    # 11/29/2007 SR: recode agemen for African American women
    if irace == 2  # for African American women
      if menarche_age == 2
        menarche_age = 1 # recode agemen=2 (age<12) to agmen=1 [12,13]
        first_live_birth_age = 0
      end
    end # set age 1st live birth to 0
    #Console.WriteLine(string.Format("CurrentAge:{0} ProjectionAge:{1}", CurrentAge, ProjectionAge));
    i = 1
    while i <= 15
      # i-1=14 ==> current age=85, max for curre
      if ti < @tvar[i - 1]
        #TODO CHECK THE INDEX
        ni = i - 1 # ni holds the index for current
        break
      end
      i += 1
    end #goto L70;
    i = 1
    while i <= 15
      if ts <= @tvar[i - 1]
        #!!!TODO CHECK THE INDEX
        ns = i - 1 # ns holds the index for risk as
        break
      end
      i += 1
    end #goto L80;
    incr = 0
    if riskindex == 2 and irace < 7
      #HACK CHECK THIS
      incr = 3
    end
    # for race specific "avg women"
    # otherwise use cols 1,2,3 depen
    # on users race                5
    # use cols 4,5,6 from rmu, rla
    #TODO Check this
    # select race specific
    cindx = 0 #column index
    cindx = incr + irace - 1
    #Console.WriteLine("------------------Contents of rmu");
    i = 0
    while i < 14
      @rmu[i] = @rmu2[i][cindx] # competeing baseline h
      @rlan[i] = @rlan2[i][cindx]
      i += 1
    end # br ca composite incid
    #Console.WriteLine(string.Format("{0} {1} {2}", i, cindx, rmu[i].ToString("F")));
    #Console.WriteLine("ns={0}", ns);
    #PrintArray(rlan, "rlan");
    #PrintArray(rmu, "rmu");
    @rf[0] = @rf2[0][incr + irace - 1] # selecting correct fac
    @rf[1] = @rf2[1][incr + irace - 1] # based on race
    if riskindex == 2 and irace >= 7
      @rf[0] = @rf2[0][12] # selecting correct fac
      @rf[1] = @rf2[1][12]
    end # based on race
    if riskindex >= 2  #&& irace < 7)
      # set risk factors to
      menarche_age = 0 # baseline age menarchy
      number_of_biopsy = 0 # # of previous biop
      first_live_birth_age = 0 # age 1st live birth
      first_deg_relatives = 0 # # 1st degree relat
      rhyp = 1.0
    end # set hyperplasia to 1.0
    ilev = age_indicator * 108 + menarche_age * 36 + number_of_biopsy * 12 + first_live_birth_age * 3 + first_deg_relatives + 1 # matrix of
    # covariate
    # range of 1
    # AgeIndicator: age ge 50 ind  0=[20, 50)
    # 1=[50, 85)
    # MenarcheAge: age menarchy   0=[14, 39] U 99 (unknown)
    # 1=[12, 14)
    # 2=[ 7, 12)
    # NumberOfBiopsy: # biopsy       0=0 or (99 and ever had biopsy=99
    # 1=1 or (99 and ever had biopsy=1 y
    # 2=[ 2, 30]
    # FirstLiveBirthAge: age 1st live   0=<20, 99 (unknown)
    # 1=[20, 25)
    # 2=[25, 30) U 0
    # 3=[30, 55]
    # FirstDegRelatives: 1st degree rel 0=0, 99 (unknown)
    # 1=1
    # 2=[2, 31]
    # **  Correspondence between exposure level and covariate factors X
    # **  in the logistic model
    # **  i-to-X correspondence
    # index in r8i
    k = 0
    while k < 216
      # col1: intercept had_biopsy
      r8i_tox2[k][0] = 1.0
      k += 1
    end
    k = 0
    while k < 108
      # col2: indicator for age
      r8i_tox2[k][1] = 0.0
      r8i_tox2[108 + k][1] = 1.0
      k += 1
    end
    j = 1
    while j <= 2
      # col3: age menarchy cate
      k = 1
      while k <= 36
        r8i_tox2[(j - 1) * 108 + k - 1][2] = 0.0
        r8i_tox2[(j - 1) * 108 + 36 + k - 1][2] = 1.0
        r8i_tox2[(j - 1) * 108 + 72 + k - 1][2] = 2.0
        k += 1
      end
      j += 1
    end
    j = 1
    while j <= 6
      # col4: # biopsy cate
      k = 1
      while k <= 12
        r8i_tox2[(j - 1) * 36 + k - 1][3] = 0.0
        r8i_tox2[(j - 1) * 36 + 12 + k - 1][3] = 1.0
        r8i_tox2[(j - 1) * 36 + 24 + k - 1][3] = 2.0
        k += 1
      end
      j += 1
    end
    j = 1
    while j <= 18
      # col5: age 1st live birt
      k = 1
      while k <= 3
        r8i_tox2[(j - 1) * 12 + k - 1][4] = 0.0
        r8i_tox2[(j - 1) * 12 + 3 + k - 1][4] = 1.0
        r8i_tox2[(j - 1) * 12 + 6 + k - 1][4] = 2.0
        r8i_tox2[(j - 1) * 12 + 9 + k - 1][4] = 3.0
        k += 1
      end
      j += 1
    end
    j = 1
    while j <= 72
      # col6: # 1st degree re
      r8i_tox2[(j - 1) * 3 + 1 - 1][5] = 0.0
      r8i_tox2[(j - 1) * 3 + 2 - 1][5] = 1.0
      r8i_tox2[(j - 1) * 3 + 3 - 1][5] = 2.0
      j += 1
    end
    i = 0
    while i < 216
      # col8: age 1st live*# r
      # col7: age*#biop intera
      r8i_tox2[i][6] = r8i_tox2[i][1] * r8i_tox2[i][3]
      r8i_tox2[i][7] = r8i_tox2[i][4] * r8i_tox2[i][5]
      i += 1
    end
    i = 0
    while i < 216
      #HACK r8i_tox2[i + 1727] = 1.0;
      r8i_tox2[i][8] = 1.0
      i += 1
    end
    # **  Computation of breast cancer risk
    # **  sum(bi*Xi) for all covariate patterns
    i = 0
    while i < 216
      # ln relative risk from BCDDP
      @sumb[i] = 0.0
      j = 0
      while j < 8
        @sumb[i] += @bet[j] * r8i_tox2[i][j]
        j += 1
      end
      i += 1
    end
    i = 1
    while i <= 108
      # eliminate int
      @sumbb[i - 1] = @sumb[i - 1] - @bet[0]
      i += 1
    end
    i = 109
    while i <= 216
      # eliminate intercept
      @sumbb[i - 1] = @sumb[i - 1] - @bet[0] - @bet[1]
      i += 1
    end
    j = 1
    while j <= 6
      # age specific baseline hazard
      @rlan[j - 1] *= @rf[0]
      j += 1
    end
    j = 7
    while j <= 14
      # age specific baseline hazard a
      @rlan[j - 1] *= @rf[1]
      j += 1
    end
    i = ilev # index ilev of range 1-
    # setting i to covariate p
    #HACK CHECK LOG VALUE
    @sumbb[i - 1] += Math.log(rhyp)
    if i <= 108
      @sumbb[i + 107] += Math.log(rhyp)
    end
    #Console.WriteLine("sumbb  0th Elmnt {0} 107th Elmnt{1}", sumbb[0], sumbb[107]);
    if ts <= @tvar[ni]
      # same 5 year age risk in
      # age & projection age wi
      @abs[i - 1] = 1.0 - Math.exp(-(@rlan[ni - 1] * Math.exp(@sumbb[i - 1]) + @rmu[ni - 1]) * (ts - ti))
      @abs[i - 1] = @abs[i - 1] * @rlan[ni - 1] * Math.exp(@sumbb[i - 1]) / (@rlan[ni - 1] * Math.exp(@sumbb[i - 1]) + @rmu[ni - 1])
    else # breast cance
      # 5 year age risk interval
      # calculate risk from
      # 1st age interval
      # age & projection age not i
      @abs[i - 1] = 1.0 - Math.exp(-(@rlan[ni - 1] * Math.exp(@sumbb[i - 1]) + @rmu[ni - 1]) * (@tvar[ni] - ti))
      @abs[i - 1] = @abs[i - 1] * @rlan[ni - 1] * Math.exp(@sumbb[i - 1]) / (@rlan[ni - 1] * Math.exp(@sumbb[i - 1]) + @rmu[ni - 1]) # age in
      # risk f
      if ns - ni > 0
        if (projection_age) > 50.0 and (current_age) < 50.0
          # a
          # s
          # a
          # calculate ris
          # last age inte
          #
          # Console.WriteLine("value of r={0} ns={1} i={2}", r.ToString("F5"), ns.ToString("F5"), i.ToString("F5"));
          # Console.WriteLine("rlan[ns - 1] \t sumbb[i + 107] \t rmu[ns - 1] \t ts \t t[ns - 1] \t math");
          # Console.Write("{0} \t {1} \t {2} \t {3} \t {4}", rlan[ns - 1].ToString("F5"), sumbb[i + 107].ToString("F5"), rmu[ns - 1].ToString("F5"), ts.ToString("F5"), t[ns - 1].ToString("F5"));
          # Console.Write(" \t {0}", Math.exp(sumbb[i + 107]).ToString("F5"));
          # Console.WriteLine();
          #
          r = 1.0 - Math.exp(-(@rlan[ns - 1] * Math.exp(@sumbb[i + 107]) + @rmu[ns - 1]) * (ts - @tvar[ns - 1]))
          #Console.WriteLine("value of r {0}: ", r.ToString("F5"));
          r = r * @rlan[ns - 1] * Math.exp(@sumbb[i + 107]) / (@rlan[ns - 1] * Math.exp(@sumbb[i + 107]) + @rmu[ns - 1])
          #Console.WriteLine("value of r {0}: ", r.ToString("F5"));
          r *= Math.exp(-(@rlan[ni - 1] * Math.exp(@sumbb[i - 1]) + @rmu[ni - 1]) * (@tvar[ni] - ti))
          #Console.WriteLine("value of r {0}: ", r.ToString("F5"));
          if ns - ni > 1
            menarche_age = ns - 1
            j = ni + 1
            while j <= menarche_age
              if @tvar[j - 1] >= 50.0
                r *= Math.exp(-(@rlan[j - 1] * Math.exp(@sumbb[i + 107]) + @rmu[j - 1]) * (@tvar[j] - @tvar[j - 1]))
              else
                r *= Math.exp(-(@rlan[j - 1] * Math.exp(@sumbb[i - 1]) + @rmu[j - 1]) * (@tvar[j] - @tvar[j - 1]))
              end
              j += 1
            end
          end
          @abs[i - 1] += r
        else
          # calculate risk from
          # last age interval
          # ages do not stradle
          r = 1.0 - Math.exp(-(@rlan[ns - 1] * Math.exp(@sumbb[i - 1]) + @rmu[ns - 1]) * (ts - @tvar[ns - 1]))
          r = r * @rlan[ns - 1] * Math.exp(@sumbb[i - 1]) / (@rlan[ns - 1] * Math.exp(@sumbb[i - 1]) + @rmu[ns - 1])
          r *= Math.exp(-(@rlan[ni - 1] * Math.exp(@sumbb[i - 1]) + @rmu[ni - 1]) * (@tvar[ni] - ti))
          if ns - ni > 1
            menarche_age = ns - 1
            j = ni + 1
            while j <= menarche_age
              r *= Math.exp(-(@rlan[j - 1] * Math.exp(@sumbb[i - 1]) + @rmu[j - 1]) * (@tvar[j] - @tvar[j - 1]))
              j += 1
            end
          end
          @abs[i - 1] += r
        end
      end
      if ns - ni > 1
        if (projection_age) > 50.0 and (current_age) < 50.0
          # calculate risk from
          # intervening age int
          menarche_age = ns - 1
          k = ni + 1
          while k <= menarche_age
            if @tvar[k - 1] >= 50.0
              r = 1.0 - Math.exp(-(@rlan[k - 1] * Math.exp(@sumbb[i + 107]) + @rmu[k - 1]) * (@tvar[k] - @tvar[k - 1]))
              r = r * @rlan[k - 1] * Math.exp(@sumbb[i + 107]) / (@rlan[k - 1] * Math.exp(@sumbb[i + 107]) + @rmu[k - 1])
            else
              r = 1.0 - Math.exp(-(@rlan[k - 1] * Math.exp(@sumbb[i - 1]) + @rmu[k - 1]) * (@tvar[k] - @tvar[k - 1]))
              r = r * @rlan[k - 1] * Math.exp(@sumbb[i - 1]) / (@rlan[k - 1] * Math.exp(@sumbb[i - 1]) + @rmu[k - 1])
            end
            r *= Math.exp(-(@rlan[ni - 1] * Math.exp(@sumbb[i - 1]) + @rmu[ni - 1]) * (@tvar[ni] - ti))
            number_of_biopsy = k - 1
            j = ni + 1
            while j <= number_of_biopsy
              if @tvar[j - 1] >= 50.0
                r *= Math.exp(-(@rlan[j - 1] * Math.exp(@sumbb[i + 107]) + @rmu[j - 1]) * (@tvar[j] - @tvar[j - 1]))
              else
                r *= Math.exp(-(@rlan[j - 1] * Math.exp(@sumbb[i - 1]) + @rmu[j - 1]) * (@tvar[j] - @tvar[j - 1]))
              end
              j += 1
            end
            @abs[i - 1] += r
            k += 1
          end
        else
          # calculate risk from
          # intervening age int
          menarche_age = ns - 1
          k = ni + 1
          while k <= menarche_age
            r = 1.0 - Math.exp(-(@rlan[k - 1] * Math.exp(@sumbb[i - 1]) + @rmu[k - 1]) * (@tvar[k] - @tvar[k - 1]))
            r = r * @rlan[k - 1] * Math.exp(@sumbb[i - 1]) / (@rlan[k - 1] * Math.exp(@sumbb[i - 1]) + @rmu[k - 1])
            r *= Math.exp(-(@rlan[ni - 1] * Math.exp(@sumbb[i - 1]) + @rmu[ni - 1]) * (@tvar[ni] - ti))
            number_of_biopsy = k - 1
            j = ni + 1
            while j <= number_of_biopsy
              r *= Math.exp(-(@rlan[j - 1] * Math.exp(@sumbb[i - 1]) + @rmu[j - 1]) * (@tvar[j] - @tvar[j - 1]))
              j += 1
            end
            @abs[i - 1] += r
            k += 1
          end
        end
      end
    end
    #Console.WriteLine("abs 0th Elmnt {0} 215th Elmnt{1}", abs[0], abs[215]);
    #Console.WriteLine("abss=", abss);
    abss = @abs[i - 1] * 1000.0
    #HACK CHECK THIS
    if abss - (abss) >= 0.5
    #abss = d_int(abss) + 1.0 ;
    abss = (abss) + 1.0
    else
      abss = (abss)
    end
    abss /= 10.0 # ** write the results to screen and output file
    #
    # Console.WriteLine("{0} {1} {2} {3} {4} {5} {6} {7} {8} {9:g} {10}",
    # CurrentAge			//[t1]
    # , ProjectionAge		//[t2]
    # , AgeIndicator		//[i0]
    # , NumberOfBiopsy	//[i2]
    # , MenarcheAge		//[i1]
    # , FirstLiveBirthAge	//[i3]
    # , FirstDegRelatives	//[i4]
    # , EverHadBiopsy		//[iever]
    # , ihyp		//[ihyp]
    # , rhyp			//[rhyp]
    # , irace				//[race]
    # );
    # Console.WriteLine(string.Format("ti={0} ts={1} ni={2} ns={3} incr={4} irace={5}", ti, ts, ni, ns, incr, irace));
    # Console.WriteLine(string.Format("ilev={0}", ilev.ToString("F")));
    # Console.WriteLine(string.Format("r={0}", r.ToString("F")));
    # Console.WriteLine("abss={0}", abss);
    #
    #
    # PrintArray(bet, "bet");
    # PrintArray(rf, "rf");
    # PrintArray(abs, "abs");
    # PrintArray(rlan, "rlan");
    # PrintArray(rmu, "rmu");
    # PrintArray(sumb, "sumb");
    # PrintArray(sumbb, "sumbb");
    # //PrintArray(t
    # PrintArray2(rmu2, "rmu2");
    # PrintArray2(rlan2, "rlan2");
    # PrintArray2(rf2, "rf2");
    # PrintArray2(r8i_tox2, "r8i_tox2");
    #
    #return
    retval = @abs[i - 1]
    return retval
  end

  def self.print_array(o, name)# had_biopsy is an array had_biopsy[]
    @log.debug('------------------Contents of '+ name)
    o.each{|d|
      @log.debug(d)
      # Console.WriteLine(System::String.Format("{0}", d.ToString("F5")))
    }
  end

  def self.print_array2(o, name)# had_biopsy is a matrix had_biopsy[][]
    @log.debug('------------------Contents of ' + name)
    o.each{|d|
      d.each{|e|
        @log.debug(e)
        # Console.WriteLine(System::String.Format("{0}", e.ToString("F5")))
      }
      # Console.WriteLine()
    }
  end
end

class BcptRace
  def initialize()
    @White = 1
    @Black = 2
    @Hispanic = 3
    @AAChinese = 7
    @AAJapanese = 8
    @AAFilipino = 9
    @AAHawaiian = 10
    @AAOtherPacificIslander = 11
    @AAOtherAsianAmerican = 12
  end
end
# <summary>
# Has static methods for converting/recoding values passed from ui or test harness
# </summary>
class BcptConvert
  def initialize()
    @_UNKNOWN = "UNKNOWN"
    @_UDERSCORE = "__"
    @_EMPTY = ""
    @_YES = "YES"
    @_NO = "NO"
    @_NA = "NA"
    @_0BIRTHS = "0 BIRTHS"
  end
  #appears in menarche
  # <summary>
  # Returns current age
  # </summary>
  # <param name="had_biopsy"></param>
  # <returns></returns>
  def self.GetCurrentAge(o)
    case o.ToString().ToUpper()
      when @_UNKNOWN, @_UDERSCORE, @_EMPTY, @_NA
        rval = 90
      when "< 35", "<35"
        rval = 34
      else
        rval = Convert.ToInt32(o)
    end
    return rval
  end

  # <summary>
  # Returns Projection Age
  # </summary>
  # <param name="had_biopsy"></param>
  # <returns></returns>
  def self.GetProjectionAge(o)
    case o
      when @_UNKNOWN, @_UDERSCORE, @_EMPTY, @_NA
        rval = 90
      else
        rval = Convert.ToInt32(o)
    end
    return rval
  end

  # <summary>
  # Returns Menarche Age
  # </summary>
  # <param name="had_biopsy"></param>
  # <returns></returns>
  def self.GetMenarcheAge(o)
    case o
      when @_UNKNOWN, @_UDERSCORE, @_EMPTY, @_NA, @_0BIRTHS
        rval = 99
      when "7 TO 11"
        rval = 10
      when "12 TO 13"
        rval = 13
      when "> 13"
        rval = 15
      else
        rval = o
    end
    #HACK CHECK AND UNCOMMENT THIS BEFORE BUILDING TO QA/PROD
    #if (rval < 7 || rval > 39 && rval != 99)
    #{
    #    string ERR_MENARCHE_1 = "!!! ERROR CONDITION !!! Menarche age coded as:   {0}. Valid menarche ages are 7 thru 39.";
    #    throw new Exception(string.Format(ERR_MENARCHE_1, rval));
    #}
    return rval
  end

  # <summary>
  # Returns First Live BirthAge
  # </summary>
  # <param name="had_biopsy"></param>
  # <returns></returns>
  def self.GetFirstLiveBirthAge(o)
    case o.Trim().ToUpper()
      when @_UNKNOWN, @_UDERSCORE, @_EMPTY, @_NA
        rval = 99
      when "NO BIRTHS"
        rval = 0
      when "< 20"
        rval = 15
      when "20 TO 24"
        rval = 22
      when "25 TO 30"
        rval = 27
      when "> 30"
        rval = 31
      else
        rval = Convert.ToInt32(o)
    end
    #HACK UNCOMMENT THIS BEFORE BUILDING TO QA/PROD
    #if (rval <= 10)
    #{
    #    string ERR_FLB_1 = "!!! ERROR CONDITION !!! Age of 1st live birth coded as: {0} Outside of valid range of 10 to 55.";
    #    throw new Exception(string.Format(ERR_FLB_1, rval));
    #}
    return rval
  end

  # <summary>
  # Returns Number First Degree Relatives
  # </summary>
  # <param name="had_biopsy"></param>
  # <returns></returns>
  def self.GetFirstDegRelatives(o)
    case o.Trim().ToUpper()
      when @_UNKNOWN, @_UDERSCORE, @_EMPTY, @_NA
        rval = 99
      when "0"
        rval = 0
      when "1"
        rval = 1
      when "> 1"
        rval = 2
      else
        rval = Convert.ToInt32(o)
    end
    return rval
  end

  # <summary>
  # Returns whether the person Ever Had Biopsy
  # </summary>
  # <param name="had_biopsy"></param>
  # <returns></returns>
  def self.GetEverHadBiopsy(had_biopsy)
    rval = 99
    case had_biopsy
      when @_UNKNOWN, @_UDERSCORE, @_EMPTY, @_NA
        rval = 99
      when @_NO, "0"
        rval = 0
      when @_YES, "1"
        rval = 1
    end
    #default:
    #    rval = Convert.ToInt32(had_biopsy);
    #    break;
    return rval
  end

  # <summary>
  # Returns Number of Biopsy
  # </summary>
  # <param name="had_biopsy"></param>
  # <returns></returns>
  def self.GetNumberOfBiopsy(o)
    case o
      when @_UNKNOWN, @_UDERSCORE, @_EMPTY, @_NA
        rval = 99
      when "1"
        rval = 1
      when "> 1"
        rval = 2
      else
        rval = o
    end
    return rval
  end

  # <summary>
  # Returns whether the person had Hyper Plasia or not
  # </summary>
  # <param name="had_biopsy"></param>
  # <returns></returns>
  def self.GetHyperPlasia(o)
    case o
      when @_UNKNOWN, @_UDERSCORE, @_EMPTY, @_NA
        rval = 99
      when @_NO
        rval = 0
      when @_YES
        rval = 1
      else
        rval = o
    end
    return rval
  end

  # <summary>
  # Returns race/ethnicity
  # </summary>
  # <param name="had_biopsy"></param>
  # <returns></returns>
  def self.GetRace(o)
    case o
      when "WHITE", @_UNKNOWN, "1", "4" #! recode other race to white 5/12/00
        rval = BcptRace.White
      when "BLACK", "2"
        rval = BcptRace.Black
      when "HISPANIC", "3"
        rval = BcptRace.Hispanic
      when "7"
        rval = BcptRace.AAChinese
      when "8"
        rval = BcptRace.AAJapanese
      when "9"
        rval = BcptRace.AAFilipino
      when "10"
        rval = BcptRace.AAHawaiian
      when "11"
        rval = BcptRace.AAOtherPacificIslander
      when "12"
        rval = BcptRace.AAOtherAsianAmerican
      else
        rval = BcptRace.White
    end
    return rval
  end

  # <summary>
  # Returns Current Age Indicator/Index
  # </summary>
  # <param name="currentAge"></param>
  # <returns></returns>
  def self.CurrentAgeIndicator(currentAge)
    rval = 0
    if currentAge < 50 then
      rval = 0
    elsif currentAge >= 50 then
      rval = 1
    end
    return rval
  end

  # <summary>
  # gets the menarche age
  # </summary>
  # <param name="menarcheAge"></param>
  # <returns></returns>
  def self.MenarcheAge(menarcheAge)
    rval = 0
    if menarcheAge >= 7 and menarcheAge < 12 then
      rval = 2
    elsif menarcheAge >= 12 and menarcheAge < 14 then
      rval = 1
    elsif menarcheAge >= 14 and menarcheAge <= 39 or menarcheAge == 99 then
      rval = 0
    end
    return rval
  end

  # <summary>
  # Returns First Live Birth Age
  # </summary>
  # <param name="firstLiveBirthAge"></param>
  # <returns></returns>
  def self.FirstLiveBirthAge(firstLiveBirthAge)
    rval = 0
    if firstLiveBirthAge == 0 then
      # no live birth
      rval = 2
    elsif firstLiveBirthAge > 0 then
      if firstLiveBirthAge < 20 or firstLiveBirthAge == 99 then # includes unknown
        rval = 0
      elsif firstLiveBirthAge >= 20 and firstLiveBirthAge < 25 then
        rval = 1
      elsif firstLiveBirthAge >= 25 and firstLiveBirthAge < 30 then
        rval = 2
      elsif firstLiveBirthAge >= 30 and firstLiveBirthAge <= 55 then
        rval = 3
      end
    end
    return rval
  end

  # <summary>
  # Returns Number of first degree relatives
  # </summary>
  # <param name="firstDegRelatives"></param>
  # <returns></returns>
  def self.FirstDegRelatives(firstDegRelatives)
    rval = 0
    if firstDegRelatives == 0 or firstDegRelatives == 99 then
      rval = 0
    elsif firstDegRelatives == 1 then
      rval = 1
    elsif firstDegRelatives >= 2 and firstDegRelatives <= 31 then
      rval = 2
    end
    return rval
  end

  # <summary>
  # Returns Number of first degree relatives based on race
  # </summary>
  # <param name="firstDegRelatives"></param>
  # <returns></returns>
  def self.FirstDegRelatives(firstDegRelatives, race)
    rval = 0
    if firstDegRelatives == 0 or firstDegRelatives == 99 then
      rval = 0
    elsif firstDegRelatives == 1 then
      rval = 1
    elsif firstDegRelatives >= 2 and firstDegRelatives <= 31 and race < 7 then
      rval = 2
    elsif firstDegRelatives >= 2 and race >= 7 then
      rval = 1
    end
    return rval
  end

  # <summary>
  # Returns whether a woman ever had biopsy or not
  # </summary>
  # <param name="ever_had_biopsy"></param>
  # <returns></returns>
  def self.EverHadBiopsy(everHadBiopsy)
    rval = 0
    case everHadBiopsy
      when 99
        #case 0:
        rval = 0
      else
        rval = everHadBiopsy
    end
    return rval
  end

  # <summary>
  # Returns Number Of Biopsies
  # </summary>
  # <param name="number_of_prev_biopsy"></param>
  # <param name="ever_had_biopsy"></param>
  # <returns></returns>
  def self.number_of_biopsy(number_of_prev_biopsy, ever_had_biopsy)
    rval = 0
    if ever_had_biopsy == 99 then
      rval = 99
    elsif number_of_prev_biopsy == 0 or (number_of_prev_biopsy == 99 and ever_had_biopsy == 99) then
      rval = 0
    elsif number_of_prev_biopsy == 1 or (number_of_prev_biopsy == 99 and ever_had_biopsy == 1) then
      rval = 1
    elsif number_of_prev_biopsy > 1 then#and number_of_prev_biopsy <= 30 then
      rval = 2
    end
    return rval
  end

  # <summary>
  # Returns Hyperlasia value
  # </summary>
  # <param name="hyperplasia"></param>
  # <param name="ever_had_biopsy"></param>
  # <returns></returns>
  def self.hyperplasia(hyperplasia, ever_had_biopsy)
    unless ever_had_biopsy
      rval = 99
    else
      # case hyperplasia
      #   else
          rval = hyperplasia
      # end
    end
    return rval
  end

  # <summary>
  # Returns RHyperplasia value
  # </summary>
  # <param name="hyperplasia"></param>
  # <returns></returns>
  def self.r_hyperplasia(hyperplasia)
    case hyperplasia
      when 1 # hyperplasia=yes
        rval = 1.82
      when 0 # hyperplasia=no
        rval = 0.93
      else # hyperplasia=never had biopsy
        rval = 1.0
    end
    return rval
  end
end