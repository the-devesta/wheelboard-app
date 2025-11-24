import 'package:flutter/material.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F4),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildServiceInfoCard(),
                      const SizedBox(height: 24),
                      _buildPricingAndHoursCard(),
                      const SizedBox(height: 24),
                      _buildAboutServiceCard(),
                      const SizedBox(height: 24),
                      _buildGalleryCard(),
                      const SizedBox(height: 24),
                      _buildStatsCard(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFF36969),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          'Service Detail',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://i.pravatar.cc/400?img=2', // Placeholder
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Professional Tyre Repair',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF36969),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Verified',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfoCard() {
    return _buildCard(
      children: [
        const Text(
          'Professional Tyre Repair Service',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Chip(
          label: const Text('Tyre Repair'),
          backgroundColor: const Color(0xFFF36969).withOpacity(0.1),
          labelStyle: const TextStyle(color: Color(0xFFF36969)),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(Icons.location_on, 'Raj Tyre Works, Surat, Gujarat'),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.star, '4.6 (132 reviews)'),
      ],
    );
  }

  Widget _buildPricingAndHoursCard() {
    return _buildCard(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDetailItem(Icons.currency_rupee, '₹1,200', 'Flat Rate'),
            _buildDetailItem(Icons.build, 'On-premise', 'Service Location'),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDetailItem(Icons.date_range, 'Mon–Sat', 'Available Days'),
            _buildDetailItem(Icons.access_time, '10 AM – 6 PM', 'Working Hours'),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutServiceCard() {
    return _buildCard(
      children: [
        const Text(
          'About this Service',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF36969).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Professional tyre repair and replacement service with over 10 years of experience. We provide on-site service for all types of vehicles including cars, bikes, and commercial vehicles. Our expert technicians use quality materials and modern equipment to ensure long-lasting repairs.',
            style: TextStyle(color: Colors.black54, height: 1.5),
          ),
        )
      ],
    );
  }

  Widget _buildGalleryCard() {
    return _buildCard(
      children: [
        const Text(
          'Gallery',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://i.pravatar.cc/150?img=${index + 10}', // Placeholder
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return _buildCard(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(Icons.lightbulb, '12', 'Leads'),
            _buildStatItem(Icons.visibility, '120', 'Views'),
            _buildStatItem(Icons.assignment, '5', 'Assigns'),
          ],
        )
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFF36969)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                const Text('Edit Service', style: TextStyle(color: Color(0xFFF36969))),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFF36969)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFF36969))),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF36969).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Color(0xFFF36969)),
            onPressed: () {},
          ),
        )
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF36969),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'View Assigns',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFF36969).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFFF36969)),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
