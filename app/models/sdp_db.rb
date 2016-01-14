module SdpDB

  PhaseDB = {
    # name => [phase_id, propal_id]
	  'Bundle Management'                                    =>[44824,41681], #
    'Continuous Improvement'                               =>[44826,41682], #
    'Quality Assurance'                                    =>[44825,41683], #
    'Provisions'			                                     =>[44827,41684], #
    # name => [phase_id, propal_id]
    'WP1.1 - Quality Control'                              =>[44742,41664], #
    'WP1.2 - Quality Assurance'                            =>[44743,41664], #
    'WP1.3 - BAT'                                          =>[44744,41664], #
    'WP1.4 - Agility'                                      =>[44745,41664], #
    'WP1.5 - SQR'                                          =>[44746,41664], #
    'WP1.6.1 - QWR, DWQAP'                                 =>[44747,41664], #
    'WP1.6.2 - QWR, Project Setting-up'                    =>[44748,41664], #
    'WP1.6.3 - QWR, WS Support, Reporting & KPI'           =>[44749,41664], #
    'WP1.6.4 - QWR, Quality Status'                        =>[44750,41664], #
    'WP1.6.5 - QWR, Spiders'                               =>[44751,41664], #
    'WP1.6.6 - QWR, QG BRD'                                =>[44752,41664], #
    'WP1.6.7 - QWR, QG TD'                                 =>[44753,41664], #
    'WP1.6.8 - QWR, Lessons Learnt'                        =>[44754,41664], #
    'WP2 - Maintenance'                                    =>[44755,00000], # WP2 - Maintenance
    'WP3 - Modeling'                                       =>[44756,41665], #
    'WP3.1 - Modeling Support'                             =>[44757,41665], #
    'WP3.2.1 - Modeling, Business Process Layout'          =>[44758,41665], #
    'WP3.2.2 - Modeling, Functional Layout (Use Cases)'    =>[44759,41665],
    'WP3.2.3 - Modeling, Information Layout (Data Model'   =>[44760,41665], # WP3.2.3 - Modeling, Information Layout (Data Model)
    'WP3.3 - Modeling BAT Specific Control'                =>[44761,41665],
    'WP3.4 - Modeling BAT Specific Production'             =>[44762,41665],
    'WP4 - Surveillance'                                   =>[44763,41666],
    'WP4.1 - Surveillance, Audit'                          =>[44764,41666],
    'WP4.2 - Surveillance, Root Causes Analysis'           =>[44765,41666],
    'WP4.3 - Surveillance, Actions Implementation & Con'   =>[44766,41666], # WP4.3 - Surveillance, Actions Implementation & Control
    'WP4.4 - Fast Root Cause Analysis'                     =>[44767,41666],
    'WP5 - Change Accompaniment'                           =>[44768,00000],
    'WP5.1 - Change: Diagnosis & Action Plan'              =>[44769,00000],
    'WP5.2 - Change: Implementation Support & Follow'      =>[44770,00000], # WP5.2 - Change: Implementation Support & Follow-up
    'WP6.1 - Coaching for Project setting-up'              =>[44771,41667],
    'WP6.2 - Coaching for Business Requirements'           =>[44772,41667],
    'WP6.3 - Coaching for Verification and Validation'     =>[44773,41667],
    'WP6.4 - Coaching for Configuration Management'        =>[44774,41667],
    'WP6.5 - Coaching for Maintenance'                     =>[44775,41667],
    "WP6.6 - Coaching HLR"                                 =>[44776,41667],
    "WP6.7 - Coaching Business Process"                    =>[44777,41667],
    "WP6.8 - Coaching Use Case"                            =>[44778,41667],
    "WP6.9 - Coaching Data Model"                          =>[44779,41667],
    "WP6.10.1 - Coaching Agility: Diag & pjt launch"       =>[44780,41667],
    "WP6.10.2 - Coaching Agility: Sprint 0 Support"        =>[44781,41667],
    "WP6.10.3 - Coaching Agility: Sprint Support"          =>[44782,41667],
    'WP6.11 - Coaching Risks Management'                   =>[44783,41667],
    'WP7.1 - Light Expertise'                              =>[44784,41668],
    'WP7.2 - Complete Expertise'                           =>[44785,41668],
    #2016 # name => [phase_id, proposal_id]
    "2016-WP1.1.1 - Quality Gate"                             => [44786,41669],
    "2016-WP1.1.2 - Milestone / CCB review preparation"       => [44787,41669],
    "2016-WP1.1.3 - Process Adherence Measurement"            => [44788,41669],
    "2016-WP1.1.4 - Quality Status of a Project"              => [44789,41669],
    "2016-WP1.1.5 - Quality of Product Document"              => [44790,41669],
    "2016-WP1.1.6 - Quality of the Configuration Management"  => [44791,41669], #
    "2016-WP1.1.7 - Quality of the Code Static Review"        => [44792,41669],
    "2016-WP1.1.8 - Quality of the Test Dossier"              => [44793,41669],
    "2016-WP1.2.1 - Quality Assurance M3-M5 / G2-G5 / sM3-sM5"=> [44794,41669], #
    "2016-WP1.2.2 - Quality Assurance M5-M10 / G5-G6"         => [44795,41669],
    "2016-WP1.2.3 - Quality Assurance Post M10 / Post G6"     => [44796,41669], #
    "2016-WP1.2.4 - Quality Assurance Agile Sprint 0"         => [44797,41669],
    "2016-WP1.2.5 - Quality Assurance Agile Sprints"          => [44798,41669],
    "2016-WP1.3.1 - DW/PLM Quality Plan"                      => [44799,41669],
    "2016-WP1.3.2 - Support KPI and Reporting"                => [44800,41669],
    "2016-WP1.3.3 - PSU (GPP LBIP Suite)"                     => [44801,41669],
    "2016-WP1.3.4 - LL"                                       => [44802,41669],
    "2016-WP1.3.5 - E-M&T Referential Change Management"      => [44803,41669],
    "2016-WP2.1 - Business Process Layout"                    => [44804,41670],
    "2016-WP2.2 - Functional Layout (Use Cases)"              => [44805,41670],
    "2016-WP2.3 - Information Layout (Data Model)"            => [44806,41670],
    "2016-WP2.4 - Modeling Update"                            => [44807,41670],
    "2016-WP3.1.1 - Root Cause Analysis (Classic Approach)"   => [44808,41678], #
    "2016-WP3.1.2 - Root Cause Analysis (Seminar Approach)"   => [44809,41678], #
    "2016-WP3.2 - Action Plan of the Root Cause Analysis"     => [44810,41678], #
    "2016-WP4.1 - Coaching Project Plan"                      => [44811,41679],
    "2016-WP4.2 - Coaching BRD"                               => [44812,41679],
    "2016-WP4.3 - Coaching V&V"                               => [44813,41679],
    "2016-WP4.4 - Coaching CMP"                               => [44814,41679],
    "2016-WP4.5 - Coaching HLR"                               => [44815,41679],
    "2016-WP4.6 - Coaching Use Case"                          => [44816,41679],
    "2016-WP4.7.1 - Diagnosis and Project Launch"             => [44817,41679],
    "2016-WP4.7.2 - Sprint 0 Support"                         => [44818,41679],
    "2016-WP4.7.3 - Sprint Coaching"                          => [44819,41679],
    "2016-WP4.8 - Risk Management"                            => [44820,41679],
    "2016-WP4.9 - E-M&T Referential"                          => [44821,41679],
    "2016-WP5.1 - Light Expertise"                            => [44822,41680],
    "2016-WP5.2 - Complete Expertise"                         => [44823,41680]
  }


    #[milestone, WP] = ID activity
    ActivityDB = {
      ['M1-M3','WP1.1 - Quality Control']                     =>192606, # CM3
      ['M3-M5','WP1.1 - Quality Control']                     =>192607, # CM5
      ['M5-M10','WP1.1 - Quality Control']                    =>192608, # CM10
      ['Post-M10','WP1.1 - Quality Control']                  =>192609, # CPostM10

      ['M1-M3','WP1.2 - Quality Assurance']                   =>192610, # AM3
      ['M3-M5','WP1.2 - Quality Assurance']                   =>192611, # AM5
      ['M5-M10','WP1.2 - Quality Assurance']                  =>192612, # AM10
      ['Post-M10','WP1.2 - Quality Assurance']                =>192613, # APostM10

      ['M3-M5','WP1.4 - Agility']                             =>192642, # AGM5
      ['M5-M10','WP1.4 - Agility']                            =>192643, # AGM10
      ['Post-M10','WP1.4 - Agility']                          =>192644, # AGPostM10

      ['M1-M3','WP1.5 - SQR']                                 =>192645, # SM3
      ['M3-M5','WP1.5 - SQR']                                 =>192646, # SM5
      ['M5-M10','WP1.5 - SQR']                                =>192647, # SM10
      ['Post-M10','WP1.5 - SQR']                              =>192648, # SPostM10

      ['All','WP1.6.1 - QWR, DWQAP']                          =>192649, # DWQAP
      ['All','WP1.6.2 - QWR, Project Setting-up']             =>192650, # PjtSetup
      ['All','WP1.6.3 - QWR, WS Support, Reporting & KPI']    =>192651, # WSSupport
      ['All','WP1.6.4 - QWR, Quality Status']                 =>192652, # QS
      ['All','WP1.6.5 - QWR, Spiders']                        =>192653, # SP
      ['All','WP1.6.6 - QWR, QG BRD']                         =>192654, # QGBRD
      ['All','WP1.6.7 - QWR, QG TD']                          =>192655, # QGTD
      ['All','WP1.6.8 - QWR, Lessons Learnt']                 =>192656, # PjtLL
      
      ['All','WP3.1 - Modeling Support']                          =>192658, # ModSupport
      ['All','WP3.2.1 - Modeling, Business Process Layout']       =>192659, # ModBPLayou
      ['All','WP3.2.2 - Modeling, Functional Layout (Use Cases)'] =>192660, # ModUC
      ['All','WP3.2.3 - Modeling, Information Layout (Data Model']=>192661, # ModDM
      ['All','WP3.3 - Modeling BAT specific Control']             =>192662, # ModBATSC
      
      ['All','WP4.1 - Surveillance, Audit']                       =>192666, # AUDIT
      ['All','WP4.2 - Surveillance, Root Causes Analysis']        =>192667, # RCA
      
      ['All','WP6.1 - Coaching for Project setting-up']           =>192668, # Coaching1A
      ['All','WP6.2 - Coaching for Business Requirements']        =>192669, # Coaching2A
      ['All','WP6.3 - Coaching for Verification and Validation']  =>192670, # Coaching3A
      ['All','WP6.4 - Coaching for Configuration Management']     =>192671, # Coaching4A
      ['All','WP6.6 - Coaching HLR']                              =>192672, # Coaching6A
      ['All','WP6.8 - Coaching Use Case']                         =>192673, # Coaching8A
      ['All','WP6.10.1 - Coaching Agility: Diag & pjt launch']    =>192674, # Coaching10
      ['All','WP6.10.2 - Coaching Agility: Sprint 0 Support']     =>192675, # Coaching10
      ['All','WP6.10.3 - Coaching Agility: Sprint Support']       =>192676, # Coaching10
      
      ['All','WP7.1 - Light Expertise']                           =>192677, # LightExper
      ['All','WP7.2 - Complete Expertise']                        =>192678, # ComplExp
      
      # BUNDLE MANAGEMENT
      ['Bundle Management','']              =>192718, # BMP
      ['Bundle Quality Assurance','']       =>192717, # BQA
      ['Operational Management',nil]        =>192720, # MQR
      ['Montée en compétences',nil]         =>192721, # MTCP
      ['Continuous Improvement','']         =>192719, # CI
      ['Sous charges',nil]                  =>192722, # SCH
      ['Incidents',nil]                     =>192723, # IRP
      ['Not sold',nil]                      =>192724, # NSO
      ['AVV BMC and other',nil]             =>192725, # AVV
      ['Provisions',nil]                    =>192726, # Prov
      ['Autre',nil]                         =>192641, # AUT

      #2016
      ['All','2016-WP1.1.1 - Quality Gate']                             =>192679, # QG
      ['All','2016-WP1.1.2 - Milestone / CCB review preparation']       =>192680, # MPrepa
      ['All','2016-WP1.1.3 - Process Adherence Measurement']            =>192681, # PAM
      ['All','2016-WP1.1.4 - Quality Status of a Project']              =>192682, # QSP
      ['All','2016-WP1.1.5 - Quality of Product Document']              =>192683, # QPD
      ['All','2016-WP1.1.6 - Quality of the Configuration Management']  =>192684, # QCM
      ['All','2016-WP1.1.7 - Quality of the Code Static Review']        =>192685, # QCSR
      ['All','2016-WP1.1.8 - Quality of the Test Dossier']              =>192686, # QTD
      ['All','2016-WP1.2.1 - Quality Assurance M3-M5 / G2-G5 / sM3-sM5']=>192687, # QAM3M5
      ['All','2016-WP1.2.2 - Quality Assurance M5-M10 / G5-G6']         =>192688, # QAM5M10
      ['All','2016-WP1.2.3 - Quality Assurance Post M10 / Post G6']     =>192689, # QAPostM10
      ['All','2016-WP1.2.4 - Quality Assurance Agile Sprint 0']         =>192690, # QAASO
      ['All','2016-WP1.2.5 - Quality Assurance Agile Sprints']          =>192691, # QAAS
      ['All','2016-WP1.3.1 - DW/PLM Quality Plan']                      =>192692, # DWPLMQAP
      ['All','2016-WP1.3.2 - Support KPI and Reporting']                =>192693, # WSSupport
      ['All','2016-WP1.3.3 - PSU (GPP LBIP Suite)']                     =>192694, # PjtSetup
      ['All','2016-WP1.3.4 - LL']                                       =>192695, # LL
      ['All','2016-WP1.3.5 - E-M&T Referential Change Management']      =>192696, #RefCM
      ['All','2016-WP2.1 - Business Process Layout']                    =>192697, # ModBPL
      ['All','2016-WP2.2 - Functional Layout (Use Cases)']              =>192698, # ModFL
      ['All','2016-WP2.3 - Information Layout (Data Model)']            =>192699, # ModIL
      ['All','2016-WP2.4 - Modeling Update']                            =>192700, # ModUpdate
      ['All','2016-WP3.1.1 - Root Cause Analysis (Classic Approach)']   =>192701, # RCAClassic
      ['All','2016-WP3.1.2 - Root Cause Analysis (Seminar Approach)']   =>192702, # RCASeminar
      ['All','2016-WP3.2 - Action Plan of the Root Cause Analysis']     =>192703, # APRCA
      ['All','2016-WP4.1 - Coaching Project Plan']                      =>192704, # CoachingPP
      ['All','2016-WP4.2 - Coaching BRD']                               =>192705, # CoachingBR
      ['All','2016-WP4.3 - Coaching V&V']                               =>192706, # CoachingVV
      ['All','2016-WP4.4 - Coaching CMP']                               =>192707, # CoachingCM
      ['All','2016-WP4.5 - Coaching HLR']                               =>192708, # CoachingHL
      ['All','2016-WP4.6 - Coaching Use Case']                          =>192709, # CoachingUC
      ['All','2016-WP4.7.1 - Diagnosis and Project Launch']             =>192710, # AgileDPL
      ['All','2016-WP4.7.2 - Sprint 0 Support']                         =>192711, # AgileS0S
      ['All','2016-WP4.7.3 - Sprint Coaching']                          =>192712, # AgileSC
      ['All','2016-WP4.8 - Risk Management']                            =>192713, # RiskM
      ['All','2016-WP4.9 - E-M&T Referential']                          =>192714, # EMnTRef
      ['All','2016-WP5.1 - Light Expertise']                            =>192715, # LightExper
      ['All','2016-WP5.2 - Complete Expertise']                         =>192716 # ComplExp

      # Activities 2014 not found in the code
      # 158502 -> Audit -> AUDIT
      # 176616 -> Autre -> AUT
      # 158545 -> AVV BMC and other -> AVV
      # 158543 -> Incidents -> IRP
      # 158544 -> Not sold -> NSO
      # 158546 -> Provisions -> Prov
      }

  # SDP Doamin
  DomainDB = {
      'EV'  =>6549, #4455 id from 2014
      'EP'  =>6548, #4454,
      'EY'  =>6551, #4457,
      'EG'  =>6558, #4464,
      'ES'  =>6550, #4456,
      'EZ'  =>6552, #4458,
      'EI'  =>6554, #4460,
      'EZC' =>6553, #4459,
      'EZMC'=>6555, #4461,
      'EZMB'=>6556, #4462,
      'EC'  =>6557 #4463
      }

  def self.sdp_phase_id(name)
    rv = PhaseDB[name]
    raise "SDPPhase '#{name}' unknown" if not rv
    rv[0]
  end

  def self.sdp_proposal_id(name)
    rv = PhaseDB[name]
    raise "Proposal '#{name}' unknown" if not rv
    rv[1]
  end

  def self.sdp_domain_id(name)
    rv = DomainDB[name]
    raise "Domain '#{name}' unknown" if not rv
    rv
  end

  def self.sdp_activity_id(arr)
    rv = ActivityDB[[arr[0],nil]] # SI [milestone,nil]
    rv = ActivityDB[arr] if not rv # Si pas [milestone,nil] alors on prend [milestone,Workpackage]
    raise "SDPActivity '[#{arr.join(',')}]' unknown" if not rv
    rv
  end

end

