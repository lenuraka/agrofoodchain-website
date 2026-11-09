<?php get_header(); ?>
<main id="main-content" class="interior-main">
 <?php while (have_posts()) : the_post(); ?>
 <section class="page-hero"><div class="wrap"><div class="kicker kicker-light">AGRO FOOD CHAIN / EXPERTISE</div><h1><?php the_title(); ?></h1><div class="page-rule"></div></div></section>
 <article class="wrap page-article" id="post-<?php the_ID(); ?>"><?php the_content(); ?>
 <?php if (is_page('contact')) : ?>
 <?php $email = get_theme_mod('afc_contact_email', ''); $phone = get_theme_mod('afc_contact_phone', ''); ?>
 <div class="contact-panel"><h2>Contact our team</h2><p>For projects, supplier audits and advisory enquiries, please include the country, sector and scope.</p>
 <?php if ($email): ?><p><strong>Email:</strong> <a href="mailto:<?php echo esc_attr($email); ?>"><?php echo esc_html($email); ?></a></p><?php endif; ?>
 <?php if ($phone): ?><p><strong>Telephone:</strong> <a href="tel:<?php echo esc_attr(preg_replace('/[^0-9+]/','',$phone)); ?>"><?php echo esc_html($phone); ?></a></p><?php endif; ?>
 <?php if (!$email && !$phone): ?><p class="draft-note">Contact details have not yet been configured. Add a verified company email or contact form before publishing.</p><?php endif; ?>
 </div>
 <?php endif; ?>
 </article><?php endwhile; ?>
</main>
<?php get_footer(); ?>
