import os
import json
import urllib.request
import urllib.parse
import time

LOCALITIES_DIR = os.path.join('assets', 'images', 'localities')
os.makedirs(LOCALITIES_DIR, exist_ok=True)

# Curated lookup for localities with accurate provinces and distinct fun facts
LOCALITY_METADATA = {
    # Region 1 - NCR
    "MANILA": {
        "name_en": "City of Manila", "name_fil": "Lungsod ng Maynila",
        "province_en": "Metro Manila", "province_fil": "Kalakhang Maynila",
        "desc_en": "Manila is the historic capital of the Philippines and the center of national government, education, and commerce, featuring the walled city of Intramuros.",
        "desc_fil": "Ang Maynila ang makasaysayang kabisera ng Pilipinas at sentro ng pamahalaan, edukasyon, at kalakalan na tahanan ng Intramuros.",
        "fact_en": "Intramuros, built in 1571, is the oldest district in Manila and was completely surrounded by thick stone defensive walls!",
        "fact_fil": "Ang Intramuros na itinayo noong 1571 ang pinakamatandang distrito sa Maynila at napalilibutan ng makakapal na pader na bato!"
    },
    "QUEZON": {
        "name_en": "Quezon City", "name_fil": "Lungsod Quezon",
        "province_en": "Metro Manila", "province_fil": "Kalakhang Maynila",
        "desc_en": "Quezon City was the former capital of the Philippines from 1948 to 1976 and is the most populous city in the country, named after President Manuel L. Quezon.",
        "desc_fil": "Ang Lungsod Quezon ay dating kabisera ng Pilipinas mula 1948 hanggang 1976 at siyang pinakamataong lungsod sa bansa.",
        "fact_en": "The Quezon Memorial Circle features a 66-meter shrine representing Manuel L. Quezon's age when he passed away!",
        "fact_fil": "Ang Quezon Memorial Circle ay may 66-metrong bantayog na sumisimbolo sa edad ni Pangulong Quezon nang siya ay pumanaw!"
    },
    "CALOOCAN": {
        "name_en": "Caloocan City", "name_fil": "Lungsod ng Caloocan",
        "province_en": "Metro Manila", "province_fil": "Kalakhang Maynila",
        "desc_en": "Caloocan is a historic city in northern Metro Manila famous for the Katipunan revolution and the iconic Bonifacio Monument.",
        "desc_fil": "Ang Caloocan ay isang makasaysayang lungsod sa hilagang Metro Manila na kilala sa himagsikang Katipunan at Monumento ni Bonifacio.",
        "fact_en": "Caloocan is the only city in the Philippines divided into two geographically separated sections: North and South Caloocan!",
        "fact_fil": "Ang Caloocan ang nag-iisang lungsod sa Pilipinas na nahahati sa dalawang magkahiwalay na bahagi: Hilaga at Timog Caloocan!"
    },
    "MAKATI": {
        "name_en": "Makati City", "name_fil": "Lungsod ng Makati",
        "province_en": "Metro Manila", "province_fil": "Kalakhang Maynila",
        "desc_en": "Makati is the leading financial, commercial, and economic center of the Philippines, hosting major banks, embassies, and corporation headquarters.",
        "desc_fil": "Ang Makati ang pangunahing sentro ng pananalapi, komersyo, at ekonomiya ng bansa na tahanan ng mga bangko at embahada.",
        "fact_en": "During business hours, Makati's daytime population swells to over four million people due to commuters and workers!",
        "fact_fil": "Sa oras ng trabaho, ang populasyon ng Makati sa araw ay umaabot sa mahigit apat na milyong tao dahil sa mga manggagawa!"
    },
    "PASIG": {
        "name_en": "Pasig City", "name_fil": "Lungsod ng Pasig",
        "province_en": "Metro Manila", "province_fil": "Kalakhang Maynila",
        "desc_en": "Pasig is an ancient settlement along the Pasig River that evolved into a premier residential and industrial hub with the modern Ortigas Center.",
        "desc_fil": "Ang Pasig ay isang sinaunang pamayanan sa tabi ng Ilog Pasig na naging maunlad na sentro ng komersyo at Ortigas Center.",
        "fact_en": "The name 'Pasig' comes from an old Sanskrit word meaning a river that flows from one body of water to another!",
        "fact_fil": "Ang pangalang 'Pasig' ay nagmula sa sinaunang salita na nangangahulugang ilog na dumadaloy mula sa isang anyong tubig patungo sa iba!"
    },
    "TAGUIG": {
        "name_en": "Taguig City", "name_fil": "Lungsod ng Taguig",
        "province_en": "Metro Manila", "province_fil": "Kalakhang Maynila",
        "desc_en": "Taguig is a fast-growing metropolitan city home to Bonifacio Global City (BGC), a world-class financial and commercial business district.",
        "desc_fil": "Ang Taguig ay isang mabilis umunlad na lungsod na tahanan ng Bonifacio Global City (BGC), isang modernong sentro ng negosyo.",
        "fact_en": "The name Taguig came from 'mga taga-giik', referring to early farmers who threshed harvested rice by treading on foot!",
        "fact_fil": "Nagmula ang pangalang Taguig sa 'mga taga-giik' na tumutukoy sa mga sinaunang magsasakang naggigiik ng palay sa pamamagitan ng pagtapak!"
    },
    "PARANAQUE": {
        "name_en": "Parañaque City", "name_fil": "Lungsod ng Parañaque",
        "province_en": "Metro Manila", "province_fil": "Kalakhang Maynila",
        "desc_en": "Parañaque is a coastal city known for entertainment complexes, the Baclaran National Shrine, and flourishing trade along Manila Bay.",
        "desc_fil": "Ang Parañaque ay isang baybaying lungsod na kilala sa Pambansang Dambana ng Baclaran at masiglang kalakalan sa Look ng Maynila.",
        "fact_en": "Baclaran Church in Parañaque welcomes over one hundred thousand pilgrims every Wednesday for the Our Mother of Perpetual Help novena!",
        "fact_fil": "Ang Simbahan ng Baclaran sa Parañaque ay dinarayo ng mahigit isandaang libong deboto tuwing Miyerkules para sa novena!"
    },
    "MARIKINA": {
        "name_en": "Marikina City", "name_fil": "Lungsod ng Marikina",
        "province_en": "Metro Manila", "province_fil": "Kalakhang Maynila",
        "desc_en": "Marikina is hailed as the 'Shoe Capital of the Philippines' for its centuries-old leathercraft and shoe-making industry.",
        "desc_fil": "Ang Marikina ang 'Kabisera ng Sapatos sa Pilipinas' dahil sa daan-taong industriya ng paggawa ng de-kalidad na sapatos.",
        "fact_en": "Marikina built the World's Largest Pair of Shoes, recognized by the Guinness World Records, measuring over 5.2 meters long!",
        "fact_fil": "Gawa ng Marikina ang Pinakamalaking Pares ng Sapatos sa Daigdig na kinilala ng Guinness World Records na may habang 5.2 metro!"
    },
    "MUNTINLUPA": {
        "name_en": "Muntinlupa City", "name_fil": "Lungsod ng Muntinlupa",
        "province_en": "Metro Manila", "province_fil": "Kalakhang Maynila",
        "desc_en": "Muntinlupa is known as the 'Emerald City of the Philippines' and the southern gateway to the CALABARZON region along Laguna de Bay.",
        "desc_fil": "Ang Muntinlupa ang 'Emerald City ng Pilipinas' at timog na lagusan patungong rehiyon ng CALABARZON sa baybayin ng Laguna de Bay.",
        "fact_en": "Muntinlupa was once a quiet agricultural village known for duck-raising and balut production along the freshwater lakeshore!",
        "fact_fil": "Ang Muntinlupa ay dating payapang nayon ng pagsasaka na kilala sa pag-aalaga ng itik at paggawa ng balut sa tabi ng lawa!"
    },
    "VALENZUELA": {
        "name_en": "Valenzuela City", "name_fil": "Lungsod ng Valenzuela",
        "province_en": "Metro Manila", "province_fil": "Kalakhang Maynila",
        "desc_en": "Valenzuela is a premier industrial city in northern Metro Manila, named in honor of Katipunan hero Dr. Pío Valenzuela.",
        "desc_fil": "Ang Valenzuela ay isang industriyal na lungsod sa hilagang Metro Manila na ipinangalan sa bayaning si Dr. Pío Valenzuela.",
        "fact_en": "The historic Bell Tower of San Diego de Alcala Church in Valenzuela survived total devastation during the battle of 1945!",
        "fact_fil": "Ang makasaysayang Kampanaryo ng Simbahan ng San Diego de Alcala sa Valenzuela ay nakaligtas sa pagkawasak noong digmaan ng 1945!"
    },
    "LASPINAS": {
        "name_en": "Las Piñas City", "name_fil": "Lungsod ng Las Piñas",
        "province_en": "Metro Manila", "province_fil": "Kalakhang Maynila",
        "desc_en": "Las Piñas is celebrated globally for its unique Bamboo Organ housed in St. Joseph Parish Church and its traditional salt beds.",
        "desc_fil": "Tanyag ang Las Piñas sa buong daigdig dahil sa Bamboo Organ sa Simbahan ng San Jose at tradisyonal na pag-aasin.",
        "fact_en": "The Las Piñas Bamboo Organ has 1,031 pipes, of which 902 are constructed entirely out of native Philippine bamboo!",
        "fact_fil": "Ang Bamboo Organ ng Las Piñas ay may 1,031 na tubo kung saan 902 sa mga ito ay gawa sa tunay na kawayang Pilipino!"
    },
    "MANDALUYONG": {
        "name_en": "Mandaluyong City", "name_fil": "Lungsod ng Mandaluyong",
        "province_en": "Metro Manila", "province_fil": "Kalakhang Maynila",
        "desc_en": "Mandaluyong is known as the 'Tiger City of the Philippines' and the 'Shopping Mall Capital' for its concentration of retail centers.",
        "desc_fil": "Ang Mandaluyong ay tinaguriang 'Tiger City ng Pilipinas' at sentro ng mga naglalakihang shopping mall sa Kamaynilaan.",
        "fact_en": "Mandaluyong houses the headquarters of the Asian Development Bank (ADB), serving 68 member economies across the region!",
        "fact_fil": "Sa Mandaluyong matatagpuan ang pandaigdigang punong-tanggapan ng Asian Development Bank (ADB) para sa 68 bansang kasapi!"
    },
    "NAVOTAS": {
        "name_en": "Navotas City", "name_fil": "Lungsod ng Navotas",
        "province_en": "Metro Manila", "province_fil": "Kalakhang Maynila",
        "desc_en": "Navotas is the 'Commercial Fishing Hub of the Philippines', supplying fish and seafood to markets all across Metro Manila.",
        "desc_fil": "Ang Navotas ang 'Kabisera ng Pangisdaan sa Pilipinas' na nagsusuplay ng isda at pagkaing-dagat sa buong Kamaynilaan.",
        "fact_en": "The Navotas Fish Port Complex is the largest fish landing and processing facility in Southeast Asia!",
        "fact_fil": "Ang Navotas Fish Port Complex ang pinakamalaking daungan at pamilihan ng isda sa buong Timog-Silangang Asya!"
    },
    "PASAY": {
        "name_en": "Pasay City", "name_fil": "Lungsod ng Pasay",
        "province_en": "Metro Manila", "province_fil": "Kalakhang Maynila",
        "desc_en": "Pasay is the premier travel and aviation gateway of the country, home to the Ninoy Aquino International Airport (NAIA) and the CCP complex.",
        "desc_fil": "Ang Pasay ang pangunahing daungan sa himpapawid ng bansa na tahanan ng Paliparang Pandaigdig ng Ninoy Aquino at CCP.",
        "fact_en": "Pasay was named after Dayang-dayang Pasay, a noble princess of the ancient kingdom of Namayan who inherited the coastal territory!",
        "fact_fil": "Ipinangalan ang Pasay kay Dayang-dayang Pasay, isang maharlikang prinsesa ng kaharian ng Namayan noong sinaunang panahon!"
    },
    "SANJUAN": {
        "name_en": "San Juan City", "name_fil": "Lungsod ng San Juan",
        "province_en": "Metro Manila", "province_fil": "Kalakhang Maynila",
        "desc_en": "San Juan is a historic city famous as the site of the Pinaglabanan battle, the first major armed conflict of the Philippine Revolution in 1896.",
        "desc_fil": "Ang San Juan ay makasaysayang lungsod kung saan naganap ang Unang Labanan ng Himagsikang Pilipino noong 1896 sa Pinaglabanan.",
        "fact_en": "Every June 24, San Juan celebrates the 'Wattah Wattah Festival' where residents joyfully douse each other with water in honor of St. John the Baptist!",
        "fact_fil": "Tuwing Hunyo 24, ipinagdiriwang sa San Juan ang 'Wattah Wattah Festival' kung saan masayang nagbabasaan ang mga mamamayan!"
    },

    # Region 2 - CAR
    "BAGUIO": {
        "name_en": "Baguio City", "name_fil": "Lungsod ng Baguio",
        "province_en": "Benguet", "province_fil": "Benguet",
        "desc_en": "Baguio is the 'Summer Capital of the Philippines', situated high in the Cordillera mountains known for pine trees, cool climate, and the Panagbenga Festival.",
        "desc_fil": "Ang Baguio ang 'Summer Capital ng Pilipinas' sa kabundukan ng Benguet na kilala sa malamig na klima at Pista ng Panagbenga.",
        "fact_en": "The name Baguio comes from the Ibaloi word 'bagiw', referring to the abundant moss that grew around Burnham Lake!",
        "fact_fil": "Ang pangalang Baguio ay nagmula sa salitang Ibaloi na 'bagiw' na tumutukoy sa lumot na tumutubo sa paligid ng Lawa ng Burnham!"
    },
    "BANAUE": {
        "name_en": "Banaue", "name_fil": "Banaue",
        "province_en": "Ifugao", "province_fil": "Ifugao",
        "desc_en": "Banaue is internationally acclaimed for its ancient 2,000-year-old mountain Rice Terraces hand-carved by indigenous Ifugao ancestors.",
        "desc_fil": "Tanyag ang Banaue sa buong daigdig dahil sa 2,000-taong Hagdan-hagdang Palayan na inukit sa bundok ng mga ninunong Ifugao.",
        "fact_en": "If the Banaue Rice Terraces were laid end to end, their total length would stretch halfway around the globe!",
        "fact_fil": "Kung pagdurugtungin ang mga pilapil ng Hagdan-hagdang Palayan sa Banaue, aabot ang haba nito sa kalahati ng bilog ng mundo!"
    },
    "LATRINIDAD": {
        "name_en": "La Trinidad", "name_fil": "La Trinidad",
        "province_en": "Benguet", "province_fil": "Benguet",
        "desc_en": "La Trinidad is the capital of Benguet and the official 'Strawberry Capital of the Philippines', providing fresh strawberries and cut flowers nationwide.",
        "desc_fil": "Ang La Trinidad ang kabisera ng Benguet at 'Strawberry Capital ng Pilipinas' na kilala sa masasarap na presa at bulaklak.",
        "fact_en": "La Trinidad baked the World's Largest Strawberry Shortcake in 2004, serving slices to over 42,000 festival visitors!",
        "fact_fil": "Nagluto ang La Trinidad ng Pinakamalaking Strawberry Shortcake sa Daigdig noong 2004 na pinagsaluhan ng mahigit 42,000 katao!"
    },
    "SAGADA": {
        "name_en": "Sagada", "name_fil": "Sagada",
        "province_en": "Mountain Province", "province_fil": "Mountain Province",
        "desc_en": "Sagada is a tranquil mountain town famous for its ancient hanging coffins cliffside burial rituals, limestone caves, and coffee farms.",
        "desc_fil": "Ang Sagada ay isang bulubunduking bayan na tanyag sa mga nakabiting kabaong sa bangin, kuweba ng Sumaguing, at kape.",
        "fact_en": "Traditional hanging coffins were placed high up on limestone cliffs so spirits could be closer to ancestral skies!",
        "fact_fil": "Ang mga kabaong sa Sagada ay ibinibitin sa mataas na bangin upang ang mga kaluluwa ay mas mapalapit sa kalangitan!"
    },

    # Region 3 - Region I (Ilocos Region)
    "LAOAG": {
        "name_en": "Laoag City", "name_fil": "Lungsod ng Laoag",
        "province_en": "Ilocos Norte", "province_fil": "Ilocos Norte",
        "desc_en": "Laoag is the vibrant capital city of Ilocos Norte, known as the 'Sunshine City' of the north. It serves as the primary commercial and educational hub of the province with rich Spanish-era heritage.",
        "desc_fil": "Ang Laoag ay ang masiglang kabisera ng Ilocos Norte na kilala bilang 'Sunshine City' ng hilaga. Ito ang pangunahing sentro ng komersyo at edukasyon sa lalawigan na may mayamang pamana noong panahon ng Espanyol.",
        "fact_en": "The famous Sinking Bell Tower of Laoag sinks into the sandy ground at an estimated rate of one inch per year!",
        "fact_fil": "Ang tanyag na Sinking Bell Tower ng Laoag ay lumulubog sa mabuhanging lupa sa tinatayang bilis na isang pulgada bawat taon!"
    },
    "VIGAN": {
        "name_en": "City of Vigan", "name_fil": "Lungsod ng Vigan",
        "province_en": "Ilocos Sur", "province_fil": "Ilocos Sur",
        "desc_en": "Vigan is a UNESCO World Heritage City renowned for having the best-preserved Spanish colonial architecture in Asia, characterized by cobblestone streets and heritage ancestral homes.",
        "desc_fil": "Ang Vigan ay isang UNESCO World Heritage City na tanyag sa pagkakaroon ng pinakamahusay na napreserbang arkitekturang kolonyal ng Espanya sa Asya na may batong daan sa Calle Crisologo.",
        "fact_en": "Horse-drawn carriages called 'kalesas' are still actively used as daily transport through the historic cobblestone streets of Vigan!",
        "fact_fil": "Ang mga kalesa na hinihila ng kabayo ay ginagamit pa rin bilang pang-araw-araw na transportasyon sa makasaysayang Calle Crisologo sa Vigan!"
    },
    "SANFERNANDO": {
        "name_en": "San Fernando City", "name_fil": "Lungsod ng San Fernando",
        "province_en": "La Union", "province_fil": "La Union",
        "desc_en": "San Fernando is the capital of La Union and the regional administrative center of Region I, situated along picturesque San Fernando Bay.",
        "desc_fil": "Ang San Fernando ang kabisera ng La Union at sentrong pampangasiwaan ng Rehiyon I na matatagpuan sa tabi ng Look ng San Fernando.",
        "fact_en": "San Fernando is home to Pindangan Ruins, where the coral walls of an 18th-century stone church still stand preserved!",
        "fact_fil": "Sa San Fernando matatagpuan ang Pindangan Ruins kung saan nakatayo pa rin ang mga kural na pader ng lumang simbahan mula ika-18 siglo!"
    },
    "DAGUPAN": {
        "name_en": "Dagupan City", "name_fil": "Lungsod ng Dagupan",
        "province_en": "Pangasinan", "province_fil": "Pangasinan",
        "desc_en": "Dagupan is an independent component city in Pangasinan, nationally celebrated as the 'Bangus Capital of the Philippines' for its world-famous milkfish aquaculture.",
        "desc_fil": "Ang Dagupan ay isang malayang bahaging lungsod sa Pangasinan na tanyag sa buong bansa bilang 'Bangus Capital ng Pilipinas' dahil sa malawak nitong palaisdaan.",
        "fact_en": "Dagupan holds a Guinness World Record for the Longest Barbecue Grill, grilling thousands of fresh bangus simultaneously!",
        "fact_fil": "Nakamit ng Dagupan ang Guinness World Record para sa Pinakamahabang Ihawan kung saan sabay-sabay na inihaw ang libo-libong sariwang bangus!"
    },
    "ALAMINOS": {
        "name_en": "Alaminos City", "name_fil": "Lungsod ng Alaminos",
        "province_en": "Pangasinan", "province_fil": "Pangasinan",
        "desc_en": "Alaminos is a coastal city in western Pangasinan and the gateway to the breathtaking Hundred Islands National Park, featuring over 120 scenic coral islands.",
        "desc_fil": "Ang Alaminos ay isang baybaying lungsod sa kanlurang Pangasinan at ang lagusan patungo sa kamangha-manghang Hundred Islands National Park na may mahigit 120 pulo.",
        "fact_en": "The islands of Hundred Islands are estimated to be over two million years old and were ancient coral reefs lifted from the sea!",
        "fact_fil": "Ang mga pulo sa Hundred Islands ay tinatayang mahigit dalawang milyong taong gulang na mga sinaunang coral reef na umangat mula sa dagat!"
    },
    "BATAC": {
        "name_en": "City of Batac", "name_fil": "Lungsod ng Batac",
        "province_en": "Ilocos Norte", "province_fil": "Ilocos Norte",
        "desc_en": "Batac is known as the 'Home of Great Leaders' in Ilocos Norte and is famous for its vibrant culinary tradition, particularly the golden-crispy Batac empanada.",
        "desc_fil": "Ang Batac ay kilala bilang 'Tahanan ng mga Dakilang Lider' sa Ilocos Norte at tanyag sa masarap na tradisyon sa pagluluto tulad ng malasang Batac empanada.",
        "fact_en": "Batac celebrates an annual Empanada Festival featuring street dancing with costumes made entirely of traditional food packaging materials!",
        "fact_fil": "Ipinagdiriwang sa Batac ang taunang Empanada Festival kung saan ang mga kasuotan sa sayawan ay gawa sa mga materyales ng tradisyonal na empanada!"
    },
    "CANDON": {
        "name_en": "City of Candon", "name_fil": "Lungsod ng Candon",
        "province_en": "Ilocos Sur", "province_fil": "Ilocos Sur",
        "desc_en": "Candon is celebrated as the 'Tobacco Capital of the Philippines' and produces renowned Virginia tobacco and mouthwatering calamay delicacies.",
        "desc_fil": "Ang Candon ang 'Kabisera ng Tabako sa Pilipinas' sa Ilocos Sur na tanyag din sa masarap at malagkit na kalamay.",
        "fact_en": "Candon's traditional calamay is packaged inside polished coconut shells tied with colorful red strings!",
        "fact_fil": "Ang tradisyonal na kalamay ng Candon ay inilalagay sa loob ng makikintab na bao ng niyog na may pulang panali!"
    },
    "URDANETA": {
        "name_en": "Urdaneta City", "name_fil": "Lungsod ng Urdaneta",
        "province_en": "Pangasinan", "province_fil": "Pangasinan",
        "desc_en": "Urdaneta is a booming commercial and logistics crossroads in eastern Pangasinan connecting central and northern Luzon.",
        "desc_fil": "Ang Urdaneta ay isang maunlad na sentro ng komersyo at transportasyon sa silangang Pangasinan na nag-uugnay sa Gitna at Hilagang Luzon.",
        "fact_en": "Urdaneta operates one of the largest bagsakan livestock and agricultural trading markets in northern the Philippines!",
        "fact_fil": "Sa Urdaneta matatagpuan ang isa sa pinakamalalaking bagsakan ng mga alagang hayop at gulay sa buong Hilagang Luzon!"
    },
    "LINGAYEN": {
        "name_en": "Lingayen", "name_fil": "Lingayen",
        "province_en": "Pangasinan", "province_fil": "Pangasinan",
        "desc_en": "Lingayen is the provincial capital of Pangasinan, famous for its grand Capitol Building, the historic Lingayen Gulf landing, and authentic bagoong production.",
        "desc_fil": "Ang Lingayen ang kabisera ng Pangasinan na kilala sa magandang Gusali ng Kapitolyo, Look ng Lingayen, at paggawa ng bagoong.",
        "fact_en": "General Douglas MacArthur led the Allied liberation forces landing upon Lingayen Gulf beach on January 9, 1945!",
        "fact_fil": "Dumaong si Heneral Douglas MacArthur at ang Sandatahang Alyado sa dalampasigan ng Look ng Lingayen noong Enero 9, 1945!"
    },
    "SANCARLOS": {
        "name_en": "San Carlos City", "name_fil": "Lungsod ng San Carlos",
        "province_en": "Pangasinan", "province_fil": "Pangasinan",
        "desc_en": "San Carlos is the most populous component city in Pangasinan, known for its extensive bamboo handicraft industry and mango orchards.",
        "desc_fil": "Ang San Carlos ang pinakamataong lungsod sa Pangasinan na kilala sa mga produktong kawayan at taniman ng matatamis na mangga.",
        "fact_en": "San Carlos was historically named 'Binalatongan' because of the abundance of monggo beans that grew on its fertile plains!",
        "fact_fil": "Ang San Carlos ay dating tinawag na 'Binalatongan' dahil sa saganang tanim na balatong o monggo sa kapatagan nito!"
    },
    "NARVACAN": {
        "name_en": "Narvacan", "name_fil": "Narvacan",
        "province_en": "Ilocos Sur", "province_fil": "Ilocos Sur",
        "desc_en": "Narvacan is a coastal heritage town nestled between green hills and the sea, known for its bagnet delicacy and outdoor paragliding adventures.",
        "desc_fil": "Ang Narvacan ay isang baybaying bayan sa Ilocos Sur na kilala sa malutong na bagnet at magagandang tanawin sa kaburulan.",
        "fact_en": "Narvacan's name arose when Spanish shipwreck survivors cried out 'Nalbakan?', an Ilocano word asking 'Where were we shipwrecked?'",
        "fact_fil": "Nagmula ang pangalang Narvacan sa tanong ng mga Espanyol na 'Nalbakan?' na nangangahulugang 'Saan tayo napaalpas o nasiraan ng barko?'"
    },
    "BAUANG": {
        "name_en": "Bauang", "name_fil": "Bauang",
        "province_en": "La Union", "province_fil": "La Union",
        "desc_en": "Bauang is a coastal municipality in La Union celebrated as the 'Grape Capital of the Philippines' with picturesque vineyards and beach resorts.",
        "desc_fil": "Ang Bauang ay isang baybaying bayan sa La Union na tinaguriang 'Grape Capital ng Pilipinas' dahil sa mga ubasan at dalampasigan.",
        "fact_en": "Bauang proves that temperate grapes can thrive bountifully in tropical Philippine soil and sunshine!",
        "fact_fil": "Pinatunayan ng Bauang na ang ubas ay maaaring mamunga nang sagana sa mainit at tropikal na klima ng Pilipinas!"
    },
    "BOLINAO": {
        "name_en": "Bolinao", "name_fil": "Bolinao",
        "province_en": "Pangasinan", "province_fil": "Pangasinan",
        "desc_en": "Bolinao is situated at the northwestern tip of Pangasinan, famous for the pristine white sand of Patar Beach and the historic Cape Bolinao Lighthouse overlooking the South China Sea.",
        "desc_fil": "Ang Bolinao ay matatagpuan sa hilagang-kanlurang dulo ng Pangasinan, kilala sa puting buhangin ng Patar Beach at sa makasaysayang Parola ng Cape Bolinao.",
        "fact_en": "Cape Bolinao Lighthouse is the second-tallest lighthouse in the Philippines and has guided maritime navigation since 1905!",
        "fact_fil": "Ang Parola ng Cape Bolinao ang ikalawang pinakamataas na parola sa Pilipinas na gumagabay sa mga barko mula pa noong 1905!"
    },
    "MANAOAG": {
        "name_en": "Manaoag", "name_fil": "Manaoag",
        "province_en": "Pangasinan", "province_fil": "Pangasinan",
        "desc_en": "Manaoag is a historic pilgrimage municipality in Pangasinan, housing the Minor Basilica of Our Lady of Manaoag which attracts millions of devotees each year.",
        "desc_fil": "Ang Manaoag ay isang banal na bayang debosyon sa Pangasinan kung saan matatagpuan ang Minor Basilica of Our Lady of Manaoag na dinarayo ng milyun-milyong deboto.",
        "fact_en": "According to folklore, the town's name comes from the Pangasinan word 'taoag', meaning 'to call', from an apparition calling an indigenous farmer!",
        "fact_fil": "Ayon sa kuwento, ang pangalan ng bayan ay hango sa salitang Pangasinan na 'taoag' na nangangahulugang 'tumawag' dahil sa isang aparisyon!"
    },
    "CURRIMAO": {
        "name_en": "Currimao", "name_fil": "Currimao",
        "province_en": "Ilocos Norte", "province_fil": "Ilocos Norte",
        "desc_en": "Currimao is a peaceful coastal town in Ilocos Norte known for its coral rock formations, tranquil beaches, and historic role as an active maritime trading port.",
        "desc_fil": "Ang Currimao ay isang mapayapang baybaying bayan sa Ilocos Norte na kilala sa mga batong kura-kural, magagandang dalampasigan, at daungang pangkalakalan.",
        "fact_en": "Its name originated during the Spanish period from watchtower sentries shouting 'Correr!' to warn residents of incoming pirate vessels!",
        "fact_fil": "Nagmula ang pangalan nito noong panahon ng Kastila mula sa sigaw na 'Correr!' ng mga bantay sa tore upang magbabala sa paparating na pirata!"
    }
}

def format_title_case(word):
    return word.capitalize()

def get_wiki_image_url(term):
    # Try direct title first
    enc = urllib.parse.quote(term.replace(' ', '_'))
    url = f'https://en.wikipedia.org/w/api.php?action=query&titles={enc}&prop=pageimages&format=json&pithumbsize=600'
    req = urllib.request.Request(url, headers={'User-Agent': 'RehiyoniaApp/1.0 (info@rehiyonia.edu)'})
    try:
        data = json.loads(urllib.request.urlopen(req, timeout=5).read().decode())
        for pid, p in data.get('query', {}).get('pages', {}).items():
            if pid != '-1' and 'thumbnail' in p:
                return p['thumbnail']['source']
    except Exception:
        pass

    # Search if direct title not found
    s_enc = urllib.parse.quote(f'{term} Philippines')
    url2 = f'https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch={s_enc}&format=json'
    req2 = urllib.request.Request(url2, headers={'User-Agent': 'RehiyoniaApp/1.0 (info@rehiyonia.edu)'})
    try:
        data2 = json.loads(urllib.request.urlopen(req2, timeout=5).read().decode())
        search_res = data2.get('query', {}).get('search', [])
        if search_res:
            top_title = search_res[0]['title']
            enc_top = urllib.parse.quote(top_title.replace(' ', '_'))
            url3 = f'https://en.wikipedia.org/w/api.php?action=query&titles={enc_top}&prop=pageimages&format=json&pithumbsize=600'
            req3 = urllib.request.Request(url3, headers={'User-Agent': 'RehiyoniaApp/1.0 (info@rehiyonia.edu)'})
            data3 = json.loads(urllib.request.urlopen(req3, timeout=5).read().decode())
            for pid, p in data3.get('query', {}).get('pages', {}).items():
                if pid != '-1' and 'thumbnail' in p:
                    return p['thumbnail']['source']
    except Exception:
        pass
    return None

def download_image(url, save_path):
    req = urllib.request.Request(url, headers={
        'User-Agent': 'RehiyoniaApp/1.0 (https://rehiyonia.edu; info@rehiyonia.edu)',
        'Referer': 'https://en.wikipedia.org/'
    })
    try:
        data = urllib.request.urlopen(req, timeout=10).read()
        if len(data) > 1000 and data[:2] == b'\xff\xd8':
            with open(save_path, 'wb') as f:
                f.write(data)
            return True
    except Exception as e:
        print(f"Error downloading {url}: {e}")
    return False

def main():
    json_path = os.path.join('assets', 'data', 'regional_words.json')
    with open(json_path, 'r', encoding='utf-8') as f:
        words = json.load(f)

    print(f"Loaded {len(words)} words.")
    updated_count = 0

    for item in words:
        w = item['word']
        meta = LOCALITY_METADATA.get(w, {})
        
        # Determine names
        name_en = meta.get('name_en', format_title_case(w))
        name_fil = meta.get('name_fil', format_title_case(w))
        prov_en = meta.get('province_en', '')
        prov_fil = meta.get('province_fil', '')
        
        # Descriptions
        existing_clue = item.get('clue', '')
        desc_en = meta.get('desc_en', item.get('description_en', f"{name_en} is a prominent {item.get('category', 'locality').lower()} in the region known for its local culture and community."))
        desc_fil = meta.get('desc_fil', item.get('description_fil', existing_clue if existing_clue else f"Ang {name_fil} ay isang mahalagang pamayanan sa rehiyon na may mayamang kultura."))
        
        # Fun facts - ensure NOT identical to description!
        fact_en = meta.get('fact_en', item.get('fact_en', f"{name_en} boasts unique local traditions and historic heritage treasured by its residents!"))
        fact_fil = meta.get('fact_fil', item.get('fact_fil', f"Ang {name_fil} ay may mga natatanging tradisyon at pamanang ipinagmamalaki ng mga naninirahan dito!"))
        
        # Set fields
        item['name_en'] = name_en
        item['name_fil'] = name_fil
        item['province_en'] = prov_en
        item['province_fil'] = prov_fil
        item['description_en'] = desc_en
        item['description_fil'] = desc_fil
        item['fact_en'] = fact_en
        item['fact_fil'] = fact_fil
        
        # Image handling
        img_filename = f"{w.lower()}.jpg"
        img_rel_path = f"assets/images/localities/{img_filename}"
        img_local_path = os.path.join('assets', 'images', 'localities', img_filename)
        
        item['image_path'] = img_rel_path
        
        if not os.path.exists(img_local_path):
            print(f"Fetching image for {w}...")
            img_url = get_wiki_image_url(w)
            if img_url:
                if download_image(img_url, img_local_path):
                    print(f"  Successfully downloaded {img_filename} ({os.path.getsize(img_local_path)} bytes)")
                else:
                    print(f"  Failed download for {w}")
            else:
                print(f"  No image found on wiki for {w}")
            time.sleep(0.3)
        else:
            print(f"Image already exists for {w}")
            
        updated_count += 1

    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(words, f, indent=2, ensure_ascii=False)
    print(f"Updated regional_words.json with {updated_count} enriched localities!")

if __name__ == '__main__':
    main()
