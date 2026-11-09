<?php if (!defined('ABSPATH')) { exit; } get_header();
$asset = get_template_directory_uri() . '/assets';
?>
<main id="main-content">
<section class="board-hero" id="home"><div class="wrap board-hero-inner">
 <div class="board-hero-copy"><p class="board-eyebrow">CENTRAL ASIA <span> | </span> SUSTAINABLE AGRICULTURE <span> | </span> FOOD SAFETY <span> | </span> RESPONSIBLE BUSINESS</p>
 <h1>Building Safer Food Systems<br>and Sustainable Value Chains<br><em>Across Central Asia</em></h1>
 <p class="board-hero-desc">International certification support, supplier audits, ESG and development consulting for businesses, investors and international organisations.</p>
 <div class="board-actions"><a class="btn btn-primary" href="<?php echo esc_url(home_url('/development-projects/')); ?>">For International Partners <span>↗</span></a><a class="btn btn-outline" href="<?php echo esc_url(home_url('/services/')); ?>">For Businesses <span>↗</span></a></div>
 </div>
 <div class="hero-proof" aria-label="Key focus areas"><div><span class="hero-proof-icon">◎</span><strong>5</strong><small>Central Asian<br>Countries</small></div><div><span class="hero-proof-icon">❋</span><strong>Global</strong><small>Standards &amp;<br>Good Practices</small></div><div><span class="hero-proof-icon">♧</span><strong>Independent</strong><small>Supplier Audits<br>&amp; Due Diligence</small></div><div><span class="hero-proof-icon">↗</span><strong>Sustainable</strong><small>Growth &amp;<br>Development</small></div></div>
 </div></section>
<section class="sector-strip" aria-label="Industries and services"><div class="wrap sector-grid">
 <?php $sectors=[
 ['agriculture','Agriculture<br>&amp; Agri-Food','/agricultural-standards/'],['food-industry','Food Industry<br>&amp; Food Safety','/food-safety/'],['textiles','Textile<br>&amp; Apparel','/textile-standards/'],['esg','ESG &amp;<br>Sustainability','/esg-sustainability/'],['supplier-audits','Supplier Audits<br>&amp; Due Diligence','/supplier-audits/'],['development','Development<br>Projects','/development-projects/']
 ]; foreach($sectors as $s): ?><a class="sector-tile" href="<?php echo esc_url(home_url($s[2])); ?>"><img src="<?php echo esc_url($asset.'/images/sector-'.$s[0].'.webp'); ?>" alt="" loading="lazy"><span class="sector-title"><?php echo wp_kses_post($s[1]); ?> <span>↗</span></span></a><?php endforeach; ?>
 </div></section>
<section class="section board-services" id="services"><div class="wrap"><div class="section-intro"><div class="kicker">OUR EXPERTISE</div><h2>International standards.<br><span>Practical regional delivery.</span></h2><p>Technical support and independent assessments across the supply chain, from farms and factories to financial institutions and development programmes.</p></div>
<div class="board-service-grid">
<?php $services=[
['food','Food Safety &amp; Quality Management','FSSC 22000, ISO 22000, HACCP, BRCGS, IFS and food safety management','/food-safety/'],
['agriculture','Agricultural Standards &amp; Sustainable Production','GLOBALG.A.P., Organic, GRASP and sustainable agricultural systems','/agricultural-standards/'],
['social','Social Compliance &amp; Ethical Sourcing','Sedex/SMETA, amfori BSCI, labour standards and responsible sourcing','/social-compliance/'],
['textile','Textile Standards &amp; Sustainable Textiles','GOTS, OCS, textile traceability and supply-chain due diligence','/textile-standards/'],
['esg','ESG &amp; Sustainability','ESG assessments, ISO 14001, resource management and sustainability reporting','/esg-sustainability/'],
['supplier','Supplier Audits &amp; Due Diligence','Second-party audits, supplier verification, factory and investment due diligence','/supplier-audits/'],
['laboratory','Laboratory Services &amp; Accreditation','ISO/IEC 17025, laboratory systems and accreditation readiness','/laboratory-services/'],
['development','International Development Projects','Technical assistance, capacity building, field implementation and monitoring','/development-projects/']
];foreach($services as $s): ?><a class="board-service" href="<?php echo esc_url(home_url($s[3])); ?>"><img src="<?php echo esc_url($asset.'/icons/'.$s[0].'.svg'); ?>" alt="" width="49" height="49" loading="lazy"><h3><?php echo wp_kses_post($s[1]); ?></h3><p><?php echo esc_html($s[2]); ?></p><span class="go-link">Explore service ↗</span></a><?php endforeach; ?>
</div></div></section>
<section class="section board-development"><div class="wrap development-layout"><div><div class="kicker">INTERNATIONAL DEVELOPMENT PARTNERS</div><h2>Regional implementation.<br>Global development goals.</h2><p class="lead">AGRO FOOD CHAIN supports technical assistance, supplier assessments, capacity building and standards-based initiatives across Central Asia.</p><a class="btn btn-primary" href="<?php echo esc_url(home_url('/development-projects/')); ?>">Explore partnerships ↗</a></div><div class="development-panel"><span>OUR AREAS OF WORK</span><ul><li>Development programmes &amp; donor-funded projects</li><li>International certification and standards</li><li>Supplier selection and verification</li><li>Social compliance and ESG assessments</li><li>Training, field implementation and follow-up</li></ul></div></div></section>
<section class="board-coverage"><div class="wrap coverage-inner"><div class="coverage-title"><strong>OUR COVERAGE</strong><span>CENTRAL ASIA</span></div><div class="coverage-list"><span>🇺🇿 Uzbekistan</span><span>🇰🇿 Kazakhstan</span><span>🇰🇬 Kyrgyzstan</span><span>🇹🇯 Tajikistan</span><span>🇹🇲 Turkmenistan</span></div><div class="coverage-tag">REGIONAL EXPERTISE.<br>INTERNATIONAL STANDARDS.<br>LASTING IMPACT.</div></div></section>
<section class="board-final-cta"><div class="wrap"><div><div class="kicker kicker-light">DISCUSS YOUR PROJECT</div><h2>Building responsible value chains together.</h2><p>Tell us about your organisation, assessment scope and the country where you need support.</p></div><a class="btn btn-primary" href="<?php echo esc_url(home_url('/contact/')); ?>">Request a Proposal ↗</a></div></section>
</main><?php get_footer(); ?>
