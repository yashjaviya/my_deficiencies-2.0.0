import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:my_deficiencies/color/app_color.dart';
import 'package:my_deficiencies/common/common.dart';
import 'package:my_deficiencies/ui/home/home_screen.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: AppColor.bgColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              child: HtmlWidget(
                /*'''<div class="page-container">
<div class="page">
<div class="text-container"><span style="text-decoration: underline;"><strong><span class="t s0" data-mappings="[[23,&quot;fi&quot;]]">1. Purpose of the My Deﬁciencies App </span></strong></span></div>
<div class="text-container"><span class="t s1" data-mappings="[[4,&quot;fi&quot;]]">&nbsp; &nbsp; MyDeﬁciencies is a research-driven educational tool that highlights the nutrient-depletion risks </span> <span class="t s1">and physiological e</span><span class="t s2" data-mappings="[[0,&quot;ff&quot;]]">ﬀ</span><span class="t s1">ects associated with prescription drugs, over-the-counter medications, </span> <span class="t s1">and synthetic vitamins. It is not medical advice and does not replace consultation with a </span> <span class="t s1" data-mappings="[[5,&quot;fi&quot;]]">qualiﬁed healthcare professional. </span></div>
<div class="text-container">&nbsp;</div>
<div class="text-container"><span style="text-decoration: underline;"><strong><span class="t s0">2. Data Integrity &amp; Citation Protocol</span></strong></span></div>
<div class="text-container"><span class="t s1">&nbsp; &nbsp; What we do, and how we do it</span></div>
<div class="text-container"><span class="t s2">&nbsp; &nbsp; &bull; </span><span class="t s1">Curate peer-reviewed evidence - All claims are drawn from trusted databases&mdash;PubMed, </span> <span class="t s1">NCBI, ScienceDirect, and the Cochrane Library.</span></div>
<div class="text-container">&nbsp;</div>
<div class="text-container"><span class="t s2">&nbsp; &nbsp; &bull; </span><span class="t s1">Show our work - Every report contains clickable citations so you can inspect the original </span> <span class="t s1">study yourself.</span></div>
<div class="text-container">&nbsp;</div>
<div class="text-container"><span class="t s2">&nbsp; &nbsp; &bull; </span><span class="t s1">Refuse to guess - If no high-quality evidence exists for a requested substance, the app tells </span> <span class="t s1">you directly. </span></div>
<div class="text-container">&nbsp;</div>
<div class="text-container"><span style="text-decoration: underline;"><strong><span class="t s0">3. What You&rsquo;ll See in Each Report </span></strong></span></div>
<div class="text-container"><span class="t s2">&nbsp; &nbsp; &bull; </span><span class="t s1"><span class="t s1">Risk severity badge:&nbsp;</span></span>🔴 Severe | 🟠&nbsp;<span class="t s1"><span class="t s1">Moderate |&nbsp;</span></span>🟡&nbsp;<span class="t s1">Low | </span><span class="t s3">✅ </span><span class="t s1">Balanced</span></div>
<div class="text-container"><span class="t s2">&nbsp; &nbsp; &bull; </span><span class="t s1">Documented nutrient depletions (e.g., magnesium loss, B-vitamin demand) </span></div>
<div class="text-container"><span class="t s2">&nbsp; &nbsp; &bull; </span><span class="t s1">Short- and long-term physiological e</span><span class="t s2" data-mappings="[[0,&quot;ff&quot;]]">ﬀ</span><span class="t s1">ects (e.g., oxidative stress, Micro-biome) </span></div>
<div class="text-container"><span class="t s2">&nbsp; &nbsp; &bull; </span><span class="t s1">Clickable peer-reviewed references for every claim </span></div>
<div class="text-container">&nbsp;</div>
<div class="text-container"><span style="text-decoration: underline;"><strong><span class="t s0" data-mappings="[[24,&quot;fi&quot;]]">4. Source-Alignment Veriﬁcation</span></strong></span></div>
<div class="text-container"><span class="t s1">&nbsp; &nbsp;We know you may want proof that each reference truly supports the claim you&rsquo;re reading. </span> <span class="t s1" data-mappings="[[18,&quot;fi&quot;],[30,&quot;fl&quot;]]">Our four-step veriﬁcation workﬂow ensures that alignment: </span></div>
<div class="text-container"><span class="t s1">&nbsp; &nbsp;1. </span><span class="t s1">Direct Evidence First </span></div>
<div class="text-container"><span class="t s2">&nbsp; &nbsp; &nbsp; &nbsp;&bull; </span> <span class="t s1">Studies that investigate the exact drug, vitamin, or nutrient you entered.</span></div>
<div class="text-container">&nbsp;</div>
<div class="text-container"><span class="t s1">&nbsp; &nbsp;2. </span><span class="t s1">Mechanism Evidence Second </span></div>
<div class="text-container"><span class="t s2">&nbsp; &nbsp; &nbsp; &nbsp;&bull; </span> <span class="t s1">Research on biochemical pathways (e.g., how stimulants raise magnesium excretion).</span></div>
<div class="text-container">&nbsp;</div>
<div class="text-container"><span class="t s1">&nbsp; &nbsp;3. </span><span class="t s1">Adjacent Evidence Third </span></div>
<div class="text-container"><span class="t s2">&nbsp; &nbsp; &nbsp; &nbsp;&bull; </span><span class="t s1">High-quality reviews or nutrient-focused papers that address related mechanisms when </span> <span class="t s1">direct studies are unavailable.</span></div>
<div class="text-container">&nbsp;</div>
<div class="text-container"><span class="t s1">&nbsp; &nbsp;4. </span><span class="t s1">Transparent Tagging </span></div>
<div class="text-container"><span class="t s2">&nbsp; &nbsp; &nbsp; &nbsp;&bull; </span><span class="t s1">Each citation is marked as Direct, Mechanistic, or Adjacent so you can see its relationship to </span> <span class="t s1">the claim. </span></div>
<div class="text-container">&nbsp;</div>
<div class="text-container"><span style="text-decoration: underline;"><strong><span class="t s0">5. Limitations &amp; User Responsibilities </span></strong></span></div>
<div class="text-container"><span class="t s2">&nbsp; &nbsp;&bull; </span><span class="t s1">Evidence Gaps: Most clinical trials examine a single agent; stacking data are rare. </span></div>
<div class="text-container"><span class="t s2">&nbsp; &nbsp;&bull; </span><span class="t s1" data-mappings="[[22,&quot;fi&quot;]]">Evolving Science: New ﬁndings can change recommendations; check back for updates. </span></div>
<div class="text-container"><span class="t s2">&nbsp; &nbsp;&bull; </span><span class="t s1">Personal Variation: Genetics, diet, and lifestyle alter nutrient needs, always consult a medical </span> <span class="t s1">professional. </span></div>
</div>
</div>
<div class="page-container">
<div class="page">
<div id="pg2Overlay">&nbsp;</div>
<div id="pg2"><strong><img id="pdf2" alt="" /><span style="text-decoration: underline;"><span class="t s0">6. Talk to Your Clinician </span></span></strong></div>
<div><span class="t s1" data-mappings="[[4,&quot;fi&quot;]]">&nbsp; &nbsp;MyDeﬁciencies is designed to inform discussions with your healthcare team. Do not start, stop, </span> <span class="t s1">or change any medication or supplement regimen without&nbsp; &nbsp; &nbsp; &nbsp; professional guidance. </span></div>
<div>&nbsp;</div>
<div><span style="text-decoration: underline;"><strong><span class="t s0" data-mappings="[[23,&quot;fi&quot;]]">7. Need additional Veriﬁcation?</span></strong></span></div>
<div><span class="t s1" data-mappings="[[12,&quot;fi&quot;]]">&nbsp; &nbsp; Need a speciﬁc citation for a particular mechanism? </span></div>
<div><span class="t s2">&nbsp; &nbsp; &bull; </span><span class="t s1">Ask inside the app and the app will supply the exact reference you request or tell you if one </span> <span class="t s1">isn&rsquo;t yet published. </span></div>
<div>&nbsp;</div>
<div><span class="t s1" data-mappings="[[11,&quot;fi&quot;]]">&copy; 2025 MyDeﬁciencies. All rights reserved.</span></div>
</div>
</div>''',*/
'''
<header class="entry-header ast-no-thumbnail">
<h1 class="entry-title">Medical Disclaimer</h1>
</header>
<div class="entry-content clear" data-ast-blocks-layout="true">
<h2 class="wp-block-heading">1. Purpose of the My Deficiencies App</h2>
<p>MyDeficiencies is a research-driven educational tool that highlights the nutrient-depletion risks and physiological effects associated with prescription drugs, over-the-counter medications, and synthetic vitamins. It is not medical advice and does not replace consultation with a qualified healthcare professional.</p>
<h2 class="wp-block-heading">2. Data Integrity &amp; Citation Protocol</h2>
<p>What we do, and how we do it.</p>
<p>Curate peer-reviewed evidence &ndash; All claims are drawn from trusted databases PubMed, NCBI, ScienceDirect, and the Cochrane Library.</p>
<p>Show our work &ndash; Every report contains clickable citations so you can inspect the original study yourself.</p>
<p>Refuse to guess &ndash; If no high-quality evidence exists for a requested substance, the app tells you directly.</p>
<h2 class="wp-block-heading">3. What You&rsquo;ll See in Each Report</h2>
<p>&bull; Risk severity badge: Severe | Moderate | Low | Balanced</p>
<p>&bull; Documented nutrient depletions (e.g., magnesium loss, B-vitamin demand)</p>
<p>&bull; Short- and long-term physiological effects (e.g., oxidative stress, Micro-biome)</p>
<p>&bull; Clickable peer-reviewed references for every claim</p>
<h2 class="wp-block-heading">4. Source-Alignment Verification</h2>
<p>We know you may want proof that each reference truly supports the claim you&rsquo;re reading.</p>
<p>Our four-step verification workflow ensures that alignment:</p>
<p>Direct Evidence First</p>
<p>Studies that investigate the exact drug, vitamin, or nutrient you entered.</p>
<p>Mechanism Evidence Second</p>
<p>Research on biochemical pathways (e.g., how stimulants raise magnesium excretion).</p>
<p>Adjacent Evidence Third</p>
<p>High-quality reviews or nutrient-focused papers that address related mechanisms when direct studies are unavailable.</p>
<p>Transparent Tagging</p>
<p>Each citation is marked as Direct, Mechanistic, or Adjacent so you can see its relationship to the claim.</p>
<h2 class="wp-block-heading">5. Limitations &amp; User Responsibilities</h2>
<p>Evidence Gaps: Most clinical trials examine a single agent; stacking data are rare.</p>
<p>Evolving Science: New findings can change recommendations; check back for updates.</p>
<p>Personal Variation: Genetics, diet, and lifestyle alter nutrient needs, always consult a medical professional.</p>
<h2 class="wp-block-heading">6. Talk to Your Clinician</h2>
<p>MyDeficiencies is designed to inform discussions with your healthcare team. Do not start, stop, or change any medication or supplement regimen without professional guidance.</p>
<h2 class="wp-block-heading">7. Need additional Verification?</h2>
<p>Need a specific citation for a particular mechanism?</p>
<p>Ask inside the app and the app will supply the exact reference you request or tell you if one isn&rsquo;t yet published.</p>
<p>Disclaimer: MyDeficiencies is intended for educational and informational purposes only. It does not provide medical advice, diagnosis, or treatment, and is not a substitute for consultation with a qualified healthcare provider. Do not modify or discontinue any medication or supplement without first consulting a licensed medical professional. While we reference scientific studies, the app does not offer personalised medical recommendations. Use of this app is at your own discretion.</p>
<p>&copy; 2025 MyDeficiencies. All rights reserved.</p>
<p>Privacy Policy :-&nbsp;<a href="https://mydeficiencies.com/privacy-policy/">https://mydeficiencies.com/privacy-policy/</a></p>
<p>Terms of Use :-&nbsp;<a href="https://mydeficiencies.com/terms-and-conditions/">https://mydeficiencies.com/terms-and-conditions/</a></p>
</div>
                ''',
                // baseUrl: Uri.parse(''),
                textStyle: TextStyle(
                  color: AppColor.white,
                  fontFamily: 'gelasio',
                  fontSize: 15,
                  decorationColor: AppColor.white
                ),
              )
              /*appText(
                title: '''1. Purpose of the My Deficiencies App
MyDeficiencies is a research-driven educational tool that highlights the nutrient-depletion risks
and physiological effects associated with prescription drugs, over-the-counter medications,
and synthetic vitamins. It is not medical advice and does not replace consultation with a
qualified healthcare professional.

2. Data Integrity & Citation Protocol
  What we do, and how we do it
  • Curate peer-reviewed evidence - All claims are drawn from trusted databases—PubMed,NCBI, ScienceDirect, and the Cochrane Library.
  • Show our work - Every report contains clickable citations so you can inspect the original study yourself.
  • Refuse to guess - If no high-quality evidence exists for a requested substance, the app tells you directly.

3. What You’ll See in Each Report
	 •	 Risk severity badge: � Severe | � Moderate | � Low | ✅ Balanced
	 •	 Documented nutrient depletions (e.g., magnesium loss, B-vitamin demand)
	 •	 Short- and long-term physiological effects (e.g., oxidative stress, Micro-biome)
	 •	 Clickable peer-reviewed references for every claim
4. Source-Alignment Verification
  We know you may want proof that each reference truly supports the claim you’re reading.
  Our four-step verification workflow ensures that alignment:
  1. Direct Evidence First
  • Studies that investigate the exact drug, vitamin, or nutrient you entered.
  2. Mechanism Evidence Second
  • Research on biochemical pathways (e.g., how stimulants raise magnesium excretion).
  3. Adjacent Evidence Third
  • High-quality reviews or nutrient-focused papers that address related mechanisms when direct studies are unavailable.
  4. Transparent Tagging
  • Each citation is marked as Direct, Mechanistic, or Adjacent so you can see its relationship to the claim.
5. Limitations & User Responsibilities
• Evidence Gaps: Most clinical trials examine a single agent; stacking data are rare.
• Evolving Science: New findings can change recommendations; check back for updates.
• Personal Variation: Genetics, diet, and lifestyle alter nutrient needs, always consult a medical
professional.
6. Talk to Your Clinician
MyDeficiencies is designed to inform discussions with your healthcare team. Do not start, stop,
or change any medication or supplement regimen without professional guidance.
7. Need additional Verification?
Need a specific citation for a particular mechanism?
• Ask inside the app and the app will supply the exact reference you request or tell you if one
isn’t yet published.
© 2025 MyDeficiencies. All rights reserved.''',
                color: AppColor.white,
                fontSize: 17
              ),*/
            ),
          ),
          15.toDouble().hs,
          GestureDetector(
            onTap: () {
              // if (FirebaseAuth.instance.currentUser == null) {
              //   Get.offAll(LoginScreen());
              // } else {
                Get.offAll(HomeScreen());
              // }
            },
            child: Container(
              height: 45,
              constraints: BoxConstraints(
                maxWidth: 250
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColor.btnColor,
                border: Border.all(color: AppColor.white),
                borderRadius: BorderRadius.circular(99),
              ),
              child: appText(
                  title: 'Agree ',
                  color: AppColor.white
              ),
            ),
          ),
          (Get.mediaQuery.padding.bottom + 15).hs
        ],
      ),
    );
  }
}
