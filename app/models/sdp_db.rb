module SdpDB

  PhaseDB = {
    # name => [phase_id, propal_id]
	  'Bundle Management'                                    =>[50913,26], #
    'Continuous Improvement'                               =>[50915,28], #
    'Quality Assurance'                                    =>[50914,28], #
    'Provisions'			                                     =>[50916,39], #
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
    "2016-WP1.1.1 - Quality Gate"                             => [50875,28],
    "2016-WP1.1.2 - Milestone - CCB review preparation"       => [50876,28],
    "2016-WP1.1.3 - Process Adherence Measurement"            => [50877,28],
    "2016-WP1.1.4 - Quality Status of a Project"              => [50878,28],
    "2016-WP1.1.5 - Quality of Product Document"              => [50879,28],
    "2016-WP1.1.6 - Quality of the Configuration Management"  => [50880,28],
    "2016-WP1.1.7 - Quality of the Code Static Review"        => [50881,28],
    "2016-WP1.1.8 - Quality of the Test Dossier"              => [50882,28],
    "2016-WP1.2.1 - Quality Assurance M3-M5 - G2-G5 - sM3-sM5"=> [50883,28],
    "2016-WP1.2.2 - Quality Assurance M5-M10 - G5-G6"         => [50884,28],
    "2016-WP1.2.3 - Quality Assurance Post M10 - Post G6"     => [50885,28],
    "2016-WP1.2.4 - Quality Assurance Agile Sprint 0"         => [50886,28],
    "2016-WP1.2.5 - Quality Assurance Agile Sprints"          => [50887,28],
    "2016-WP1.3.1 - DW-PLM Quality Plan"                      => [50888,28],
    "2016-WP1.3.2 - Support KPI and Reporting"                => [50889,28],
    "2016-WP1.3.3 - PSU (GPP LBIP Suite)"                     => [50890,28],
    "2016-WP1.3.4 - LL"                                       => [50891,28],
    "2016-WP1.3.5 - E-M&T Referential Change Management"      => [50892,28],
    "2016-WP2.1 - Business Process Layout"                    => [50893,28],
    "2016-WP2.2 - Functional Layout (Use Cases)"              => [50894,28],
    "2016-WP2.3 - Information Layout (Data Model)"            => [50895,28],
    "2016-WP2.4 - Modeling Update"                            => [50896,28],
    "2016-WP3.1.1 - Root Cause Analysis (Classic Approach)"   => [50897,28],
    "2016-WP3.1.2 - Root Cause Analysis (Seminar Approach)"   => [50898,28],
    "2016-WP3.2 - Action Plan of the Root Cause Analysis"     => [50899,28],
    "2016-WP4.1 - Coaching Project Plan"                      => [50900,26],
    "2016-WP4.2 - Coaching BRD"                               => [50901,26],
    "2016-WP4.3 - Coaching V&V"                               => [50902,26],
    "2016-WP4.4 - Coaching CMP"                               => [50903,26],
    "2016-WP4.5 - Coaching HLR"                               => [50904,26],
    "2016-WP4.6 - Coaching Use Case"                          => [50905,26],
    "2016-WP4.7.1 - Diagnosis and Project Launch"             => [50906,26],
    "2016-WP4.7.2 - Sprint 0 Support"                         => [50907,26],
    "2016-WP4.7.3 - Sprint Coaching"                          => [50908,26],
    "2016-WP4.8 - Risk Management"                            => [50909,26],
    "2016-WP4.9 - E-M&T Referential"                          => [50910,26],
    "2016-WP5.1 - Light Expertise"                            => [50911,27],
    "2016-WP5.2 - Complete Expertise"                         => [50912,27]
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
      ['Bundle Management','']              =>219371, # BMP
      ['Bundle Quality Assurance','']       =>219370, # BQA
      ['Operational Management',nil]        =>219373, # MQR
      ['Montée en compétences',nil]         =>219374, # MTCP
      ['Continuous Improvement','']         =>219372, # CI
      ['Sous charges',nil]                  =>219375, # SCH
      ['Incidents',nil]                     =>219376, # IRP
      ['Not sold',nil]                      =>219377, # NSO
      ['AVV BMC and other',nil]             =>219378, # AVV
      ['Provisions',nil]                    =>219379, # Prov
      #['Autre',nil]                         =>192641, # AUT

      #2016
      ['All','2016-WP1.1.1 - Quality Gate']                                =>219332, # QG
      ['All','2016-WP1.1.2 - Milestone - CCB review preparation']          =>219333, # MPrepa
      ['All','2016-WP1.1.3 - Process Adherence Measurement']               =>219334, # PAM
      ['All','2016-WP1.1.4 - Quality Status of a Project']                 =>219335, # QSP
      ['All','2016-WP1.1.5 - Quality of Product Document']                 =>219336, # QPD
      ['All','2016-WP1.1.6 - Quality of the Configuration Management']     =>219337, # QCM
      ['All','2016-WP1.1.7 - Quality of the Code Static Review']           =>219338, # QCSR
      ['All','2016-WP1.1.8 - Quality of the Test Dossier']                 =>219339, # QTD
      ['M3-M5','2016-WP1.2.1 - Quality Assurance M3-M5 - G2-G5 - sM3-sM5'] =>219340, # QAM3M5
      ['M5-M10','2016-WP1.2.2 - Quality Assurance M5-M10 - G5-G6']         =>219341, # QAM5M10
      ['Post-M10','2016-WP1.2.3 - Quality Assurance Post M10 - Post G6']   =>219342, # QAPostM10
      ['M3-M5','2016-WP1.2.4 - Quality Assurance Agile Sprint 0']          =>219343, # QAASO
      ['M5-M10','2016-WP1.2.5 - Quality Assurance Agile Sprints']          =>219344, # QAAS
      ['All','2016-WP1.3.1 - DW-PLM Quality Plan']                         =>219345, # DWPLMQAP
      ['All','2016-WP1.3.2 - Support KPI and Reporting']                   =>219346, # WSSupport
      ['All','2016-WP1.3.3 - PSU (GPP LBIP Suite)']                        =>219347, # PjtSetup
      ['All','2016-WP1.3.4 - LL']                                          =>219348, # LL
      ['All','2016-WP1.3.5 - E-M&T Referential Change Management']         =>219349, #RefCM
      ['All','2016-WP2.1 - Business Process Layout']                       =>219350, # ModBPL
      ['All','2016-WP2.2 - Functional Layout (Use Cases)']                 =>219351, # ModFL
      ['All','2016-WP2.3 - Information Layout (Data Model)']               =>219352, # ModIL
      ['All','2016-WP2.4 - Modeling Update']                               =>219353, # ModUpdate
      ['All','2016-WP3.1.1 - Root Cause Analysis (Classic Approach)']      =>219354, # RCAClassic
      ['All','2016-WP3.1.2 - Root Cause Analysis (Seminar Approach)']      =>219355, # RCASeminar
      ['All','2016-WP3.2 - Action Plan of the Root Cause Analysis']        =>219356, # APRCA
      ['All','2016-WP4.1 - Coaching Project Plan']                         =>219357, # CoachingPP
      ['All','2016-WP4.2 - Coaching BRD']                                  =>219358, # CoachingBR
      ['All','2016-WP4.3 - Coaching V&V']                                  =>219359, # CoachingVV
      ['All','2016-WP4.4 - Coaching CMP']                                  =>219360, # CoachingCM
      ['All','2016-WP4.5 - Coaching HLR']                                  =>219361, # CoachingHL
      ['All','2016-WP4.6 - Coaching Use Case']                             =>219362, # CoachingUC
      ['All','2016-WP4.7.1 - Diagnosis and Project Launch']                =>219363, # AgileDPL
      ['All','2016-WP4.7.2 - Sprint 0 Support']                            =>219364, # AgileS0S
      ['All','2016-WP4.7.3 - Sprint Coaching']                             =>219365, # AgileSC
      ['All','2016-WP4.8 - Risk Management']                               =>219366, # RiskM
      ['All','2016-WP4.9 - E-M&T Referential']                             =>219367, # EMnTRef
      ['All','2016-WP5.1 - Light Expertise']                               =>219368, # LightExper
      ['All','2016-WP5.2 - Complete Expertise']                            =>219369  # ComplExp

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
      'EV'  =>7747, #6549 id from 2016, #4455 id from 2014
      'EP'  =>7746, #6548, #4454,
      'EY'  =>7749, #6551, #4457,
      'EG'  =>7756, #6558, #4464,
      'ES'  =>7748, #6550, #4456,
      'EZ'  =>7750, #6552, #4458,
      'EI'  =>7752, #6554, #4460,
      'EZC' =>7751, #6553, #4459,
      'EZMC'=>7753, #6555, #4461,
      'EZMB'=>7754, #6556, #4462,
      'EC'  =>7755 #6557 #4463
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

