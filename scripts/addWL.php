<?php

$address = [
    "0xE542Aa3d76c11eae3AE976602C237d51B052f666",
    "0x4fe97c29902bb1e8323eCD9B334510F200c70B52",
    "0xfF9e0CB23BeeC06caF9b0281a517D77209FbDb35",
    "0x3Cb5f59b696b9d781a5b7cCF93650AA449A9e6a2",
    "0x07a2CDCABD615BBA366E87eDad66CBc8e16AF2c8",
    "0xE4106ca1d82Cf5B384340C670068bB045560914C",
    "0x92fC15EF728100CC4bD3105fec69c3cee7dAb31a",
    "0x5cC7e03c55Fe814258D6beeC562Eb83183a4386e",
    "0xb04000c7a67002eebC5aE4dAb88DFD58929856ED",
    "0x317Fc5A5DFf51908f9daAEe869f9761713bdA0D9",
    "0xb5eD84660Ec80DDa959521c54035215d0169173B",
    "0xA4E0BCB3356f39eE76319767a0Da0948AE7C0D14",
    "0xFe8C22DAc3bAaFBF76583bC559904DAb9E4C46C9",
    "0xC67dcD7E51fdbfA321e22410EcA216d355b8e04b",
    "0xF4C24AFD10AB25364264835D42073dca54e9051b",
    "0xcF0f756df777283F97cEE0C07EfB91C20f81c2E0",
    "0x5e3fB34C5B874131fd6b5F51f17353C625D68c1C",
    "0x9BE03F92F8E324A7310707aa016E6381Ca5B3609",
    "0x338Ead47797E245ADc8a5d4733CBD2577E4362Aa",
    "0x23f08A34017966bE139dFa8e7235a47E6949938B",
];

$amounts = [
	"2",
	"2",
	"2",
	"2",
	"2",
];

for($i = 0; $i < count($address); $i ++ ) {
	$url = "https://shibkingpro.org/apiido/addWL?address=";
	$url .= $address[$i] . "&amount=2";
	var_dump($url);
	$res = file_get_contents($url);
	var_dump($res);
}
