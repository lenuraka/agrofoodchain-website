<?php if (!defined('ABSPATH')) { exit; } ?>
<footer class="site-footer">
 <div class="wrap footer-grid">
  <div><img class="footer-brand-logo" src="<?php echo esc_url(get_template_directory_uri().'/assets/images/agro-food-chain-logo.png'); ?>" alt="AGRO FOOD CHAIN"><p>International auditing, certification support and advisory services for organisations navigating complex supply chains in Central Asia.</p><p class="footer-note">Uzbekistan • Central Asia • International clients</p></div>
  <div><h3>Explore</h3><a href="<?php echo esc_url(home_url('/services/')); ?>">Our services</a><a href="<?php echo esc_url(home_url('/supplier-audits/')); ?>">Supplier audits</a><a href="<?php echo esc_url(home_url('/international-buyers/')); ?>">For international buyers</a><a href="<?php echo esc_url(home_url('/about/')); ?>">About us</a></div>
  <div><h3>Expertise</h3><a href="<?php echo esc_url(home_url('/food-safety/')); ?>">Food safety &amp; quality</a><a href="<?php echo esc_url(home_url('/agricultural-standards/')); ?>">Agricultural standards</a><a href="<?php echo esc_url(home_url('/social-compliance/')); ?>">Social compliance</a><a href="<?php echo esc_url(home_url('/textile-standards/')); ?>">Textile standards</a><a href="<?php echo esc_url(home_url('/esg-sustainability/')); ?>">ESG &amp; sustainability</a></div>
  <div><h3>Contact</h3><p>Discuss local verification, supplier assessments or certification readiness.</p>
  <?php $email=get_theme_mod('afc_contact_email',''); if ($email): ?><a href="mailto:<?php echo esc_attr($email); ?>"><?php echo esc_html($email); ?></a><?php endif; ?>
  <?php $phone=get_theme_mod('afc_contact_phone',''); if ($phone): ?><a href="tel:<?php echo esc_attr(preg_replace('/[^0-9+]/','',$phone)); ?>"><?php echo esc_html($phone); ?></a><?php endif; ?>
  <a class="footer-cta" href="<?php echo esc_url(home_url('/contact/')); ?>">Get in touch ↗</a></div>
 </div>
 <div class="wrap footer-bottom"><span>© <?php echo esc_html(wp_date('Y')); ?> AGRO FOOD CHAIN LLC. All rights reserved.</span><span>Third-party accredited certifications, where applicable, are issued by the authorised certification body—not by AGRO FOOD CHAIN unless separately authorised.</span></div>
</footer>
<?php wp_footer(); ?>
</body></html>