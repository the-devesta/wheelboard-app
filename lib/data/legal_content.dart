// ─────────────────────────────────────────────────────────────────────────────
// Canonical legal content for Wheelboard (mobile app copy).
//
// This is an EXACT mirror of the web app's `src/lib/legal/legalContent.ts` so the
// same Privacy Policy and Terms & Conditions text is shown across mobile and web
// (transcribed verbatim from the official company PDFs). Keep the two in sync.
// ─────────────────────────────────────────────────────────────────────────────

/// A single rendered block within a legal section.
/// [kind]: 'p' = paragraph, 'sub' = bold sub-heading line, 'li' = bullet item.
class LegalBlock {
  final String kind;
  final String text;
  const LegalBlock.p(this.text) : kind = 'p';
  const LegalBlock.sub(this.text) : kind = 'sub';
  const LegalBlock.li(this.text) : kind = 'li';
}

class LegalSection {
  final String? heading;
  final List<LegalBlock> blocks;
  const LegalSection({this.heading, required this.blocks});
}

class LegalDoc {
  final String title;
  final String lastUpdated;
  final List<LegalSection> sections;
  const LegalDoc({
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });
}

class LegalContact {
  static const String company = 'Wheelboard Solutions Private Limited';
  static const String email = 'hello@wheelboard.in';
  static const String phone = '020-6732049, mob: +91-7420861942';
  static const String address =
      '#204 Sapphire Chambers, First Floor, Baner Road, Baner, Pune-411045, Maharashtra';
}

const LegalDoc privacyPolicy = LegalDoc(
  title: 'Privacy Policy',
  lastUpdated: '07.01.2026',
  sections: [
    LegalSection(blocks: [
      LegalBlock.p(
          'This Privacy Policy describes how Wheelboard Solutions private limited ("Wheelboard", "we", "us", or "our") collects, uses, and shares information when you use our mobile application "Wheelboard" and any related services (collectively, the "Services"). By using the Services, you agree to the collection and use of information in accordance with this Policy.'),
    ]),
    LegalSection(heading: '1. Developer info and contact', blocks: [
      LegalBlock.li('Developer: WHEELBOARD SOLUTIONS PRIVATE LIMITED.'),
      LegalBlock.li(
          'Address: WHEELBOARD SOLUTIONS PRIVATE LIMITED, #204 Sapphire Chambers, First Floor, Baner Road, Baner, Pune-411045, Maharashtra'),
      LegalBlock.li('Email: hello@wheelboard.in'),
      LegalBlock.li('Phone: 020-6732049, mob: +91- 7420861942'),
      LegalBlock.p(
          'If you have any questions about this Policy or your personal data, you can contact us using the details above.'),
    ]),
    LegalSection(heading: '2. Information we collect', blocks: [
      LegalBlock.p(
          'Depending on how you use the app (as a fleet owner, operator, driver, mechanic, or other user), we may collect the following categories of information:'),
      LegalBlock.sub('Account and identification data:'),
      LegalBlock.li('Name, mobile number, email address'),
      LegalBlock.li(
          'Business name and role (e.g., fleet owner, driver, mechanic)'),
      LegalBlock.li(
          'Government identification details that you or your fleet owner choose to store, such as PAN, driving license number, vehicle registration number, GST or similar identifiers, as required for trip documentation and compliance.'),
      LegalBlock.sub('Vehicle and trip data:'),
      LegalBlock.li(
          'Vehicle details (registration number, make/model, chassis/engine details)'),
      LegalBlock.li(
          'Trip details (load details, LR number, origin/destination, route, distance, times, proof of delivery uploads)'),
      LegalBlock.li(
          'Fleet-related documents added by you (images/PDFs of LR, POD, permits, insurance, fitness certificates etc.).'),
      LegalBlock.sub('Location and device information (if you grant permission):'),
      LegalBlock.li(
          'Approximate or precise location data for features such as live trip tracking, route planning, and safety monitoring'),
      LegalBlock.li(
          'Device information such as device ID, operating system, app version, IP address, and log data (crash logs, performance data, and usage analytics).'),
      LegalBlock.sub('Usage and log information:'),
      LegalBlock.li(
          'Actions taken in the app (creating trips, updating status, uploading documents)'),
      LegalBlock.li(
          'Time and duration of sessions, in-app screens viewed, and basic analytics.'),
      LegalBlock.sub('Support and communication data:'),
      LegalBlock.li(
          'Information you provide when you contact support, fill forms, or give feedback (messages, attachments, and contact details).'),
      LegalBlock.p(
          'We do not knowingly collect biometric data, financial card data, or contact lists directly from your device unless explicitly required and clearly disclosed for a specific feature.'),
    ]),
    LegalSection(heading: '3. How we use your information', blocks: [
      LegalBlock.p('We use the collected information to:'),
      LegalBlock.sub('Provide and operate the Services, including:'),
      LegalBlock.li('Creating and managing user and fleet accounts'),
      LegalBlock.li(
          'Managing trips, loads, LR, POD, and other transport documentation.'),
      LegalBlock.li(
          'Enabling communication between fleet owners, dispatch teams, drivers, and service providers.'),
      LegalBlock.sub('Improve, maintain, and secure the app:'),
      LegalBlock.li(
          'Monitor performance, fix bugs, and analyze usage to enhance features'),
      LegalBlock.li('Prevent fraud, abuse, or misuse of the Services'),
      LegalBlock.li('Ensure security of accounts and data.'),
      LegalBlock.sub('Comply with legal and contractual obligations:'),
      LegalBlock.li(
          'Maintain records that may be required by applicable transport, tax, and business laws'),
      LegalBlock.li(
          'Respond to lawful requests from authorities, where applicable.'),
      LegalBlock.sub('Communicate with you:'),
      LegalBlock.li(
          'Send service-related notifications (trip status, account alerts, policy updates)'),
      LegalBlock.li('Respond to your queries, feedback, and support requests.'),
      LegalBlock.p(
          'We will only process personal data when we have a lawful basis, such as your consent, contract performance, legitimate interests, or legal obligations, as applicable under relevant laws.'),
    ]),
    LegalSection(heading: '4. Permissions and device access', blocks: [
      LegalBlock.p(
          'Certain features of Wheelboard require access to your device resources, which we request through system permissions:'),
      LegalBlock.li(
          'Location: For live tracking, route and trip management, and safety features.'),
      LegalBlock.li(
          'Camera and storage: For capturing and uploading LR, POD, vehicle documents, and other fleet-related images or files.'),
      LegalBlock.li(
          'Notifications: For sending trip alerts, reminders, and important updates.'),
      LegalBlock.p(
          'You can manage permissions at any time through your device settings, but some features may not work properly if permissions are disabled.'),
    ]),
    LegalSection(heading: '5. How we share your information', blocks: [
      LegalBlock.p(
          'We do not sell your personal data. We may share information in the following limited circumstances:'),
      LegalBlock.sub('Within your fleet or organization:'),
      LegalBlock.li(
          'Fleet owners, authorized staff, and drivers may see relevant trip, vehicle, and contact data necessary to perform logistics operations.'),
      LegalBlock.sub('Service providers and third-party partners:'),
      LegalBlock.li(
          'Hosting, cloud storage, analytics, logging, and communication tools that help us operate and improve the app.'),
      LegalBlock.li(
          'Third-party APIs or data providers used for vehicle data verification or enrichment, where integrated.'),
      LegalBlock.sub('Legal and safety requirements:'),
      LegalBlock.li(
          'To comply with applicable laws, regulations, legal processes, or government requests.'),
      LegalBlock.li(
          'To protect the rights, property, or safety of Wheelboard, our users, or others.'),
      LegalBlock.p(
          'Whenever we share data with service providers, they are required to use it only on our behalf and in line with this Policy and applicable laws.'),
    ]),
    LegalSection(heading: '6. Data storage, security, and retention', blocks: [
      LegalBlock.li(
          'Data is stored on secure servers hosted by reputable providers in [India/global], with technical and organizational measures designed to protect it against unauthorized access, alteration, disclosure, or destruction.'),
      LegalBlock.li(
          'Measures may include encryption in transit (HTTPS/TLS), access controls, backups, and monitoring.'),
      LegalBlock.p('We retain personal data only as long as necessary:'),
      LegalBlock.li('To provide the Services and maintain your account.'),
      LegalBlock.li(
          'To comply with legal, accounting, or reporting requirements.'),
      LegalBlock.li('To resolve disputes and enforce our agreements.'),
      LegalBlock.p(
          'When data is no longer needed, we will delete or anonymize it in accordance with our data retention practices and applicable law.'),
    ]),
    LegalSection(heading: '7. Your rights and choices', blocks: [
      LegalBlock.p('Depending on applicable law, you may have the right to:'),
      LegalBlock.li('Access the personal data we hold about you.'),
      LegalBlock.li('Request correction of inaccurate or incomplete data.'),
      LegalBlock.li(
          'Request deletion of your data, subject to legal and contractual obligations.'),
      LegalBlock.li('Object to or request restriction of certain processing.'),
      LegalBlock.li('Withdraw consent where processing is based on consent.'),
      LegalBlock.p(
          'To exercise these rights, contact us at [hello@wheelboard.in]. We may need to verify your identity before responding to your request.'),
      LegalBlock.p('You may also:'),
      LegalBlock.li(
          'Update some information directly in your account profile (where available)'),
      LegalBlock.li(
          'Manage app permissions at the device level (location, camera, storage, etc.)'),
    ]),
    LegalSection(heading: "8. Children's privacy", blocks: [
      LegalBlock.p(
          'Our Services are intended for use by adults in the transport and logistics industry and are not directed to children under 18. We do not knowingly collect personal data from children, and if we learn that such data has been collected, we will take reasonable steps to delete it.'),
    ]),
    LegalSection(heading: '9. International data transfers', blocks: [
      LegalBlock.p(
          'If your data is transferred or stored outside your country, it may be subject to data protection laws that differ from those in your jurisdiction. Where required, we take appropriate safeguards to protect your data in connection with such transfers.'),
    ]),
    LegalSection(heading: '10. Third-party services and links', blocks: [
      LegalBlock.p(
          'Our app may contain links to third-party websites or integrate third-party services (for example, map providers, telematics, or vehicle-data APIs). Their privacy practices are governed by their own policies, and we encourage you to review those separately. We are not responsible for the content or practices of third-party services.'),
    ]),
    LegalSection(heading: '11. Changes to this Privacy Policy', blocks: [
      LegalBlock.p(
          'We may update this Privacy Policy from time to time to reflect changes in our practices, technologies, or legal requirements. The "Last updated" date at the top indicates when this Policy was last revised. Continued use of the Services after any changes means you accept the updated Policy.'),
    ]),
    LegalSection(heading: '12. How to contact us', blocks: [
      LegalBlock.p(
          'If you have questions, concerns, or complaints about privacy or this Policy, or if you wish to exercise your rights, please contact:'),
      LegalBlock.li('Email: [hello@wheelboard.in]'),
      LegalBlock.li(
          'Address: WHEELBOARD SOLUTIONS PRIVATE LIMITED, #204 Sapphire Chambers, First Floor, Baner Road, Baner, Pune-411045, Maharashtra.'),
      LegalBlock.li('Phone: 020-6732049, mob: +91- 7420861942'),
    ]),
  ],
);

const LegalDoc termsAndConditions = LegalDoc(
  title: 'Terms and Conditions',
  lastUpdated: '[20.06.2026]',
  sections: [
    LegalSection(blocks: [
      LegalBlock.p(
          'Welcome to Wheelboard Solutions. These Terms and Conditions ("Terms") govern your access to and use of the Wheelboard Solutions website, mobile application, and related services (collectively, the "Platform"), operated by Wheelboard Solutions Private Limited ("Company," "we," "us," or "our").'),
      LegalBlock.p(
          'By accessing or using our Platform, you agree to be bound by these Terms. If you do not agree with any part of these Terms, you must not use our services.'),
    ]),
    LegalSection(heading: '1. Description of Services', blocks: [
      LegalBlock.p(
          'Wheelboard Solutions provides an integrated digital logistics ecosystem designed to connect fleet owners, drivers, mechanics, and service providers. The Platform offers tools for tracking transport profitability, operational intelligence, maintenance, and other logistics-related services.'),
    ]),
    LegalSection(heading: '2. User Registration and Accounts', blocks: [
      LegalBlock.p(
          'Eligibility: You must be at least 18 years old and capable of forming a binding contract to use this Platform.'),
      LegalBlock.li(
          'a. Account Creation: To access certain features, you must register for an account. You agree to provide accurate, current, and complete information during registration and keep your account details updated.'),
      LegalBlock.li(
          'b. Account Security: You are responsible for safeguarding your login credentials. You must promptly notify us of any unauthorized use of your account. We are not liable for any loss or damage arising from your failure to protect your account information.'),
    ]),
    LegalSection(heading: '3. Subscriptions and Payments', blocks: [
      LegalBlock.p(
          'Service Tiers: We offer various subscription tiers, including Free, Monthly, Annual, and premium Enterprise plans. Specific features, limits, and pricing for each tier are detailed on our Platform.'),
      LegalBlock.li(
          'a. Payment Terms: By selecting a paid subscription, you agree to pay all applicable fees in advance. Payments are non-refundable except as expressly required by law or stated in our refund policy.'),
      LegalBlock.li(
          'b. Modifications: We reserve the right to modify our subscription fees or introduce new charges upon reasonable prior notice to you.'),
    ]),
    LegalSection(heading: '4. User Conduct and Responsibilities', blocks: [
      LegalBlock.p(
          'You agree to use the Platform only for lawful purposes. You shall not:'),
      LegalBlock.li(
          'a. Violate any applicable local, state, national, or international law. Submit false, misleading, or fraudulent information.'),
      LegalBlock.li(
          'b. Attempt to interfere with, compromise the system integrity or security, or decipher any transmissions to or from the servers running the Platform.'),
      LegalBlock.li(
          'c. Engage in data mining, scraping, or similar data gathering and extraction methods.'),
      LegalBlock.li(
          'd. Use the Platform to transmit any malicious code, viruses, or harmful software.'),
    ]),
    LegalSection(heading: '5. Intellectual Property Rights', blocks: [
      LegalBlock.p(
          'All content, features, and functionality on the Platform—including but not limited to the "Wheelboard Solutions" trademark, software code, text, graphics, logos, and data structures—are the exclusive property of Wheelboard Solutions Private Limited and are protected by copyright, trademark, and other intellectual property laws. You may not reproduce, distribute, modify, or create derivative works without our prior written consent.'),
    ]),
    LegalSection(heading: '6. Third-Party Services', blocks: [
      LegalBlock.p(
          'The Platform may contain links to third-party websites or integrate with third-party service providers (such as payment gateways or insurance providers). We do not control these third-party services and are not responsible for their content, privacy policies, or practices. Your interactions with any third-party services are solely between you and the respective third party.'),
    ]),
    LegalSection(heading: '7. Limitation of Liability', blocks: [
      LegalBlock.p(
          'To the maximum extent permitted by applicable law, Wheelboard Solutions Private Limited and its directors, employees, partners, and agents shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, or goodwill, resulting from:'),
      LegalBlock.li(
          'a. Your access to or use of, or inability to access or use, the Platform.'),
      LegalBlock.li('b. Any conduct or content of any third party on the Platform.'),
      LegalBlock.li(
          'c. Any errors, inaccuracies, or omissions in the operational insights or metrics (such as Profit per Kilometer or Trip efficiency calculations) provided by the Platform.'),
    ]),
    LegalSection(heading: '8. Disclaimer of Warranties', blocks: [
      LegalBlock.p(
          'Your use of the Platform is at your sole risk. The service is provided on an "AS IS" and "AS AVAILABLE" basis, without any warranties of any kind, either express or implied, including, but not limited to, implied warranties of merchantability, fitness for a particular purpose, or non-infringement.'),
    ]),
    LegalSection(heading: '9. Termination', blocks: [
      LegalBlock.p(
          'We reserve the right to suspend or terminate your account and access to the Platform at our sole discretion, without prior notice or liability, for any reason, including if you breach these Terms. Upon termination, your right to use the Platform will immediately cease.'),
    ]),
    LegalSection(heading: '10. Governing Law and Jurisdiction', blocks: [
      LegalBlock.p(
          'These Terms shall be governed by and construed in accordance with the laws of India. Any disputes arising out of or in connection with these Terms or your use of the Platform shall be subject to the exclusive jurisdiction of the courts located in Pune, Maharashtra.'),
    ]),
    LegalSection(heading: '11. Changes to Terms', blocks: [
      LegalBlock.p(
          'We reserve the right to modify or replace these Terms at any time. We will provide notice of significant changes by posting the updated Terms on the Platform and updating the "Last Updated" date. Your continued use of the Platform after any such changes constitutes your acceptance of the new Terms.'),
    ]),
    LegalSection(heading: '12. Contact Information', blocks: [
      LegalBlock.p(
          'If you have any questions, concerns, or feedback regarding these Terms, please contact us at:'),
      LegalBlock.li('Wheelboard Solutions Private Limited'),
      LegalBlock.li('Email: [hello@wheelboard.in]'),
      LegalBlock.li('Address: Wheelboard solutions, Pune-412101, Maharashtra, India'),
    ]),
  ],
);
