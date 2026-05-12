import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
    Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $urlString');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Support', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () {
              final now = DateTime.now();
              final formattedDate = DateFormat('MMMM dd, yyyy').format(now);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Today is $formattedDate')),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  child: Image.asset(
                    color: Colors.blue.shade900,
                    'assets/images/support.png',
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hello, How can we\nHelp you?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildSupportOption(
                context,
                'Send us an E-mail',
                Icons.email,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EmailScreen()),
                  );
                },
              ),
              _buildSupportOption(
                context,
                'FAQs',
                Icons.question_answer,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FAQsScreen()),
                  );
                },
              ),
              _buildSupportOption(
                context,
                'Contact Us',
                Icons.support_agent,
                () async {
                  await _launchURL('tel:+919329143659');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportOption(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: <Color>[Colors.blue, Colors.purple],
                      tileMode: TileMode.mirror,
                    ).createShader(bounds);
                  },
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 16.0),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  _LiveChatScreenState createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  // List to store the chat messages
  List<Map<String, String>> messages = [];

  // Controller to handle text input
  TextEditingController _controller = TextEditingController();

  // Function to send message
  void _sendMessage() {
    if (_controller.text.isEmpty) return; // Don't send empty messages

    setState(() {
      // Add user's message
      messages.add({"sender": "user", "message": _controller.text, "timestamp": DateTime.now().toString()});

      // Add a dummy response from the support
      messages.add({
        "sender": "support",
        "message": "Thank you for your message. We will assist you shortly.",
        "timestamp": DateTime.now().toString()
      });
    });

    // Clear the input field after sending the message
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Chat", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message["sender"] == "user";

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue.shade900 : Colors.grey.shade200,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: isUser ? Radius.circular(12) : Radius.zero,
                          bottomRight: isUser ? Radius.zero : Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message["message"] ?? '',
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message["timestamp"]?.substring(11, 16) ?? '', // Show timestamp in HH:mm format
                            style: TextStyle(
                              color: isUser ? Colors.white70 : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Text input and send button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.blue.shade900,
                  iconSize: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// Screen for Email Support

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  _EmailScreenState createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  // Controllers to handle form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Function to simulate sending the email
  void _sendEmail() {
    // Just for demo: Check if the fields are not empty
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields!")),
      );
      return;
    }

    // Simulate email submission (you can replace this with real email API later)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Your email has been sent!")),
    );

    // Optionally clear the form fields
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send us an E-mail", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: 80, // Add some height to the app bar for a modern look
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              const Text(
                "We'd love to hear from you!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please fill out the form below to send us your query or feedback. We'll get back to you shortly.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),

              // Name Field
              _buildTextField(
                controller: _nameController,
                label: "Your Name",
                icon: Icons.person,
                hintText: "Enter your name",
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),

              // Email Field
              _buildTextField(
                controller: _emailController,
                label: "Your Email",
                icon: Icons.email,
                hintText: "Enter your email address",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Message Field
              _buildTextField(
                controller: _messageController,
                label: "Your Message",
                icon: Icons.message,
                hintText: "Describe your query or feedback",
                keyboardType: TextInputType.text,
                maxLines: 6,
              ),
              const SizedBox(height: 30),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: _sendEmail,
                  child: const Text(
                    "Send Message",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900, // Button color
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5, // Add a nice shadow for the button
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable method to build text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    required TextInputType keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.blue.shade900),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade900),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade900, width: 1.5),
        ),
      ),
    );
  }
}


class FAQsScreen extends StatelessWidget {
  const FAQsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Frequently Asked Questions", style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading Section
            const Text(
              "Got Questions? We've Got Answers.",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Find answers to common questions below. If you can't find what you're looking for, feel free to reach out to us.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            // FAQ List
            Expanded(
              child: ListView(
                children: [
                  _buildFAQTile(
                    "How can I contact support?",
                    "You can contact support via the 'Contact Us' page on our app or send us an email at support@example.com.",
                  ),
                  _buildFAQTile(
                    "What payment methods do you accept?",
                    "We accept credit cards, PayPal, and other popular payment methods. You can check the full list on the payment page.",
                  ),
                  _buildFAQTile(
                    "How do I reset my password?",
                    "To reset your password, go to the login page, click on 'Forgot Password', and follow the instructions to reset it.",
                  ),
                  _buildFAQTile(
                    "How do I change my account settings?",
                    "You can change your account settings by navigating to the 'Profile' section within the app. There, you can update your details.",
                  ),
                  _buildFAQTile(
                    "Where can I track my order?",
                    "You can track your order in the 'Orders' section of your profile. You will also receive email updates with tracking information.",
                  ),
                  // More questions can be added here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable method to build an FAQ tile
  Widget _buildFAQTile(String question, String answer) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5, // Subtle shadow for depth
      child: ExpansionTile(
        clipBehavior: Clip.antiAlias,
        visualDensity: VisualDensity.comfortable,
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        expandedAlignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 15.0,),
        title: Text(
          question,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade900, // Consistent color with branding
          ),
        ),
        trailing: Icon(
          Icons.arrow_drop_down,
          color: Colors.blue.shade900,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}