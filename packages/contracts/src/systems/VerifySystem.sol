// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { G1Point, G2Point, Proof, VerificationKey, Pairing } from "../lib/SnarkProof.sol";
import { MoveInput, SpawnInput, RevealInput, BiomebaseInput } from "../lib/VerificationInput.sol";
import { TempConfigSet } from "../codegen/index.sol";

// todo store verification key in tables
contract VerifySystem is System {
  function verify(uint256[] memory input, Proof memory proof, VerificationKey memory vk) internal view returns (bool) {
    uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    require(input.length + 1 == vk.IC.length, "verifier-bad-input");
    // Compute the linear combination vk_x
    G1Point memory vk_x = G1Point(0, 0);
    for (uint256 i = 0; i < input.length; i++) {
      require(input[i] < snark_scalar_field, "verifier-gte-snark-scalar-field");
      vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
    }
    vk_x = Pairing.addition(vk_x, vk.IC[0]);
    if (
      !Pairing.pairingProd4(Pairing.negate(proof.A), proof.B, vk.alfa1, vk.beta2, vk_x, vk.gamma2, proof.C, vk.delta2)
    ) return false;
    return true;
  }

  function SpawnVerifyingKey() internal pure returns (VerificationKey memory vk) {
    vk.alfa1 = G1Point(
      20491192805390485299153009773594534940189261866228447918068658471970481763042,
      9383485363053290200918347156157836566562967994039712273449902621266178545958
    );

    vk.beta2 = G2Point(
      [
        4252822878758300859123897981450591353533073413197771768651442665752259397132,
        6375614351688725206403948262868962793625744043794305715222011528459656738731
      ],
      [
        21847035105528745403288232691147584728191162732299865338377159692350059136679,
        10505242626370262277552901082094356697409835680220590971873171140371331206856
      ]
    );
    vk.gamma2 = G2Point(
      [
        11559732032986387107991004021392285783925812861821192530917403151452391805634,
        10857046999023057135944570762232829481370756359578518086990519993285655852781
      ],
      [
        4082367875863433681332203403145435568316851327593401208105741076214120093531,
        8495653923123431417604973247489272438418190587263600148770280649306958101930
      ]
    );
    vk.delta2 = G2Point(
      [
        4532625822216104936154524242655127825325790671566336691936464395230060711966,
        6266463592366608553738523625603410611589098892974483134240232839074552530680
      ],
      [
        8957806754169852577697539303574140958793652902216358930541593255148821429818,
        581195458084226350799114352008166134074543460260898475244773270517155490181
      ]
    );
    vk.IC = new G1Point[](10);

    vk.IC[0] = G1Point(
      10903192188024796188957659568074469165803627765755252253165702165814150807123,
      17136870826837228713260877110636382552392529990661367197306929619382037286294
    );

    vk.IC[1] = G1Point(
      18617792474545588627601936253174150404421163221855747585812418602522989401269,
      9973431740530208635565364008607006551520620853704177578613626175902474630798
    );

    vk.IC[2] = G1Point(
      17705999854277723893821688874574368536027901236930773525607055658800115604523,
      11093326118707152023488305179942972480027122839400447062920882699061386231637
    );

    vk.IC[3] = G1Point(
      14454830513030503732530539020791803104651225724733094070878793087244696012440,
      18827603810211341600896000112008069506088071346836105703574411513107132506028
    );

    vk.IC[4] = G1Point(
      13926175770234892084771123271141419082305481423424543612346090045638451948884,
      16136875498066552356400244753406220797924261973108765301711040691350759906108
    );

    vk.IC[5] = G1Point(
      4164978560244235368812118230153475037149597808283219168496164388453545774691,
      21561744893349742242619974671743877579041368222076293937935780737005299024655
    );

    vk.IC[6] = G1Point(
      11515903686240540533030591773076293309574655799445160290877849841139791959900,
      10509064325784873262830310189111247834810637691801172565917478901146427194138
    );

    vk.IC[7] = G1Point(
      17237139781010345662806518594881656749111508327399494932830557402558383235661,
      19384584173025081312821880294500552642568631952793229791125812296672874844311
    );

    vk.IC[8] = G1Point(
      15389746847299477480036098577509327778544642950478755345367548174084577003838,
      10710617001946768983839028921110604342061735204228264540948118075353009435502
    );

    vk.IC[9] = G1Point(
      2018193179358368569290192993495736530143529453885130558922567099394146237557,
      12250032136432094481166470147077945827433562348050828452736266476764902214346
    );
  }
  /// @return r  bool true if proof is valid

  function verifySpawnProof(Proof memory proof, SpawnInput memory input) public view returns (bool) {
    // check whether to skip proof verification
    if (TempConfigSet.getSkipProofCheck()) {
      return true;
    }

    input.validate();
    return verify(input.flatten(), proof, SpawnVerifyingKey());
  }

  function MoveVerifyingKey() internal pure returns (VerificationKey memory vk) {
    vk.alfa1 = G1Point(
      20491192805390485299153009773594534940189261866228447918068658471970481763042,
      9383485363053290200918347156157836566562967994039712273449902621266178545958
    );

    vk.beta2 = G2Point(
      [
        4252822878758300859123897981450591353533073413197771768651442665752259397132,
        6375614351688725206403948262868962793625744043794305715222011528459656738731
      ],
      [
        21847035105528745403288232691147584728191162732299865338377159692350059136679,
        10505242626370262277552901082094356697409835680220590971873171140371331206856
      ]
    );
    vk.gamma2 = G2Point(
      [
        11559732032986387107991004021392285783925812861821192530917403151452391805634,
        10857046999023057135944570762232829481370756359578518086990519993285655852781
      ],
      [
        4082367875863433681332203403145435568316851327593401208105741076214120093531,
        8495653923123431417604973247489272438418190587263600148770280649306958101930
      ]
    );
    vk.delta2 = G2Point(
      [
        3662132347962111665880628492748450810614258741673018791423412169957493997027,
        9338183953699204237286296440185813263482216562174245897573084391169704995366
      ],
      [
        11252963344336302553846664082200846092962551471208444101895068766187830495639,
        52093659542758205378568903717832949047337292713335121824673138620021496337
      ]
    );
    vk.IC = new G1Point[](12);

    vk.IC[0] = G1Point(
      4925619573743290571121554559293839970790520465941877497599466856341467392502,
      3069424169349310197316503240870684182500595065795119810044653006732932304158
    );

    vk.IC[1] = G1Point(
      11071465748560965269493125910640856917143346153502581906099308625896983085514,
      8674677261198362486016061103940742568578858137020431199572200288849705321219
    );

    vk.IC[2] = G1Point(
      19632496393721980221264972208200572065788529106981253374876673066419441098736,
      14257390579708732734489735569605945876299164322422323402899121996694641732362
    );

    vk.IC[3] = G1Point(
      14623820368888964182152434165904854781906301908824075461344739641017640678698,
      8482365593822689405526816948943241427153946787458864971609647754109811084498
    );

    vk.IC[4] = G1Point(
      18284274840464624615957544406427685534874070460727839569080372993566352892710,
      4517364569650181367457467732894139788058522304448680625238557467373617286510
    );

    vk.IC[5] = G1Point(
      12504985442733893386259939419100873047460991333238856166565149178941231595988,
      13012213605706662718636053330461905929891338444481122781162465271025058438023
    );

    vk.IC[6] = G1Point(
      13188574706977310484683937264115110864406868007570536401971198074501783952119,
      15601742351756308952685481256338700168325639666422218984495591368455724865459
    );

    vk.IC[7] = G1Point(
      13276538906953256407593618860664720926981604814362558389533230364788544662431,
      9188993535820429270618691383855806862611537154944364802840708228289926189124
    );

    vk.IC[8] = G1Point(
      17793289398228990648768203804332445995936350364522872145419068631695989422682,
      9930809677928511060381023015034216587234402056987713240124388040471752017385
    );

    vk.IC[9] = G1Point(
      8513547646552372161914451574297176921395092992092960637724160302101427805791,
      6870201461878885246100464225891052354534413354886628312733001963688508541029
    );

    vk.IC[10] = G1Point(
      1166818988517806283545521641940377878139204093133054169274000254144871309402,
      20653691506299716896530781825892051201551684770737466300483163306978748042340
    );

    vk.IC[11] = G1Point(
      15297119759749226395829869439043792982926320915300257561907328823873141772836,
      2208738937001273366405471819643934353246775491388743325632672751417206814049
    );
  }

  function verifyMoveProof(Proof memory proof, MoveInput memory input) public view returns (bool) {
    // check whether to skip proof verification
    if (TempConfigSet.getSkipProofCheck()) {
      return true;
    }

    input.validate();
    return verify(input.flatten(), proof, MoveVerifyingKey());
  }

  function BiomebaseVerifyingKey() internal pure returns (VerificationKey memory vk) {
    vk.alfa1 = G1Point(
      20491192805390485299153009773594534940189261866228447918068658471970481763042,
      9383485363053290200918347156157836566562967994039712273449902621266178545958
    );

    vk.beta2 = G2Point(
      [
        4252822878758300859123897981450591353533073413197771768651442665752259397132,
        6375614351688725206403948262868962793625744043794305715222011528459656738731
      ],
      [
        21847035105528745403288232691147584728191162732299865338377159692350059136679,
        10505242626370262277552901082094356697409835680220590971873171140371331206856
      ]
    );
    vk.gamma2 = G2Point(
      [
        11559732032986387107991004021392285783925812861821192530917403151452391805634,
        10857046999023057135944570762232829481370756359578518086990519993285655852781
      ],
      [
        4082367875863433681332203403145435568316851327593401208105741076214120093531,
        8495653923123431417604973247489272438418190587263600148770280649306958101930
      ]
    );
    vk.delta2 = G2Point(
      [
        17942644676941644645144010803838642791147726375018313070354957989291809256928,
        11782346925773711017291356068485413646254901873889177904784262016600154343626
      ],
      [
        1652170348828234741048997675627620539251866669097353405150111536454785683208,
        19015191519258821391998366376021039452680250764512541089382999323666711970428
      ]
    );
    vk.IC = new G1Point[](8);

    vk.IC[0] = G1Point(
      21250300667185525901580388559909892770452357496879527676120845005543242989760,
      10426472583883054653936279616164955222070039634513107260078220439790037060659
    );

    vk.IC[1] = G1Point(
      16983830713052827329728652935562921035177046300107635477267477929706008919698,
      5884402317348502705097831404211143317916673178755878479991895091081271187827
    );

    vk.IC[2] = G1Point(
      235782098820353863612917404089142779266660158754152816082461122322540563652,
      21535900226353074138988420228559314519157079680595643504645271527104504597296
    );

    vk.IC[3] = G1Point(
      11469041948475358315369080442347030572736889854696445758180356987743689070051,
      6828270994129044099441177236340020245751127156415094009243635730069873211999
    );

    vk.IC[4] = G1Point(
      4282838701958489600695429842820124583426374783191325021568691124204690780373,
      12146150630198409544829747685920589038354009001346688719859952199240039075333
    );

    vk.IC[5] = G1Point(
      1343102270089127879670777102185276041250412330198531134161892935475385906440,
      15974561787912711597265929337589461031201454242709736222665158458979163488582
    );

    vk.IC[6] = G1Point(
      8837988175299078498104976969943131537499712579929450114882614850266600243822,
      12610881673829132622330206814033224038161202174017140296350495504354697822506
    );

    vk.IC[7] = G1Point(
      19640392557101822115689190933858234219858807923134958140934165845198355985175,
      987070609002668985944541181145569605073916687890637727341050111436617174466
    );
  }
  /// @return r  bool true if proof is valid

  function verifyBiomebaseProof(Proof memory proof, BiomebaseInput memory input) public view returns (bool) {
    // check whether to skip proof verification
    if (TempConfigSet.getSkipProofCheck()) {
      return true;
    }

    input.validate();
    return verify(input.flatten(), proof, BiomebaseVerifyingKey());
  }

  function RevealVerifyingKey() internal pure returns (VerificationKey memory vk) {
    vk.alfa1 = G1Point(
      20491192805390485299153009773594534940189261866228447918068658471970481763042,
      9383485363053290200918347156157836566562967994039712273449902621266178545958
    );

    vk.beta2 = G2Point(
      [
        4252822878758300859123897981450591353533073413197771768651442665752259397132,
        6375614351688725206403948262868962793625744043794305715222011528459656738731
      ],
      [
        21847035105528745403288232691147584728191162732299865338377159692350059136679,
        10505242626370262277552901082094356697409835680220590971873171140371331206856
      ]
    );
    vk.gamma2 = G2Point(
      [
        11559732032986387107991004021392285783925812861821192530917403151452391805634,
        10857046999023057135944570762232829481370756359578518086990519993285655852781
      ],
      [
        4082367875863433681332203403145435568316851327593401208105741076214120093531,
        8495653923123431417604973247489272438418190587263600148770280649306958101930
      ]
    );
    vk.delta2 = G2Point(
      [
        17021206786060862710948326973913259663512179574135199805525013235623536540288,
        983343523538272194767802689319450405492435901391896712520528113929880934354
      ],
      [
        11605721080644716315629603782292064868074311633924718361171568134952007620627,
        19391274316941448822966541322965115277321679565921499192732004267096091003513
      ]
    );
    vk.IC = new G1Point[](10);

    vk.IC[0] = G1Point(
      19489790316274385309064215684183892617598815118204605779290145676644696534185,
      18651908838673315311066049243856856732783882257710098185377327057191457535858
    );

    vk.IC[1] = G1Point(
      15782886797225642248511953471996685485262381791146695019232456213347041850963,
      1258001190761567321784430099858004358638672661491204197191106617852237094627
    );

    vk.IC[2] = G1Point(
      904019761965978235927208992323552636369187706191468607016655305604307923493,
      11599213840820910407062766568708940415751512247196648645350765567323510961163
    );

    vk.IC[3] = G1Point(
      13668222988213682537756495884090444735424852101437178250496956381075244522059,
      7622976858698393431136469027105039253730031879733510569494915113090807071271
    );

    vk.IC[4] = G1Point(
      7077890826941758488454181185348922160880451641159305003028262549426672146702,
      1845643879618500641054490520445104815584376996882792477606685109814953646210
    );

    vk.IC[5] = G1Point(
      19325515405117578695852630977621373031770192339918158681126192904329757409809,
      18099082231346969622919885759307172683873904196652369350357567169062791954009
    );

    vk.IC[6] = G1Point(
      6974736369733995561717473743287309188416383796524387862207755032492073284826,
      9237072409738873235633144299875496533739514368388342978291385794650616684170
    );

    vk.IC[7] = G1Point(
      19517076238375412040901945815777431506719707068281704748316429001152673903580,
      8935618032501414798639521487381308076984802396844896442031010791968253212239
    );

    vk.IC[8] = G1Point(
      16019139553285359717694446796817997985718432714222679295698666304825466725458,
      20952255237516526733192066016242073490464353695927424975440758307619904078929
    );

    vk.IC[9] = G1Point(
      7676397886268226546946427163357365555939658876660928475861859244370582776515,
      16024771508789477450124898145926403014792762766567053214693667464273214461459
    );
  }
  /// @return r  bool true if proof is valid

  function verifyRevealProof(Proof memory proof, RevealInput memory input) public view returns (bool) {
    // check whether to skip proof verification
    if (TempConfigSet.getSkipProofCheck()) {
      return true;
    }

    input.validate();
    return verify(input.flatten(), proof, RevealVerifyingKey());
  }

  function WhitelistVerifyingKey() internal pure returns (VerificationKey memory vk) {
    vk.alfa1 = G1Point(
      20491192805390485299153009773594534940189261866228447918068658471970481763042,
      9383485363053290200918347156157836566562967994039712273449902621266178545958
    );

    vk.beta2 = G2Point(
      [
        4252822878758300859123897981450591353533073413197771768651442665752259397132,
        6375614351688725206403948262868962793625744043794305715222011528459656738731
      ],
      [
        21847035105528745403288232691147584728191162732299865338377159692350059136679,
        10505242626370262277552901082094356697409835680220590971873171140371331206856
      ]
    );
    vk.gamma2 = G2Point(
      [
        11559732032986387107991004021392285783925812861821192530917403151452391805634,
        10857046999023057135944570762232829481370756359578518086990519993285655852781
      ],
      [
        4082367875863433681332203403145435568316851327593401208105741076214120093531,
        8495653923123431417604973247489272438418190587263600148770280649306958101930
      ]
    );
    vk.delta2 = G2Point(
      [
        3043989390110463822433839272770520639894280117900947741402162798093708379844,
        15498061189652564726154836138594724559809742029038962836111093726970657942192
      ],
      [
        15618400180571545973694929665676762830056766886212467624098831682699592610533,
        11545344725200353995570147195922542752531045655155889929523910310988782333394
      ]
    );
    vk.IC = new G1Point[](3);

    vk.IC[0] = G1Point(
      5721771612911507500367883892193619600637964581065654495065873426788465036091,
      20744056121215434236621659053331055921604752750429597696100304335926512103242
    );

    vk.IC[1] = G1Point(
      6040399575979408293815866128713633868515388019044503688835587939668103903199,
      1588321754112141226662635149331554451934235764807200084294922470420432372492
    );

    vk.IC[2] = G1Point(
      4457298715940763616254131061542220439037481442470105108949533668891652571583,
      15135253555293407817429043255632614679473194204820967832764981155477491069515
    );
  }
  /// @return r  bool true if proof is valid

  function verifyWhitelistProof(
    uint256[2] memory a,
    uint256[2][2] memory b,
    uint256[2] memory c,
    uint256[2] memory input
  ) public view returns (bool) {
    // check whether to skip proof verification
    if (TempConfigSet.getSkipProofCheck()) {
      return true;
    }

    Proof memory proof;
    proof.A = G1Point(a[0], a[1]);
    proof.B = G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
    proof.C = G1Point(c[0], c[1]);

    VerificationKey memory vk = WhitelistVerifyingKey();
    uint256[] memory inputValues = new uint256[](input.length);
    for (uint256 i = 0; i < input.length; i++) {
      inputValues[i] = input[i];
    }
    return verify(inputValues, proof, vk);
  }
}
