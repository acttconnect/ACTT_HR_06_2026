import 'package:flutter/material.dart';
import '../api_services.dart';
import '../model/learning_model.dart';
import 'learning_detail.dart';

class LearningScreen extends StatefulWidget {
  @override
  _LearningScreenState createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  late Future<List<LearningData>> _learningData;

  @override
  void initState() {
    super.initState();
    _learningData = ApiService().fetchLearningData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Learning',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
      body: FutureBuilder<List<LearningData>>(
        future: _learningData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          }

          final data = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LearningDetailScreen(item: item)));
              },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row for image and text
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Image Section
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item.imageUrl.isEmpty
                                ? 'https://pinghr.in/uploads/image/1736749887.jpeg' // Default image URL
                                : item.imageUrl,
                            width: 100,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 12), // Space between image and text
                        // Column for Title and Description
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                item.title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 14, // Increased font size for readability
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // Ensuring text color is black
                                ),
                              ),
                              // Description Section
                              Text(
                                item.description,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700], // Slightly darker text for better readability
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider( // Divider below the image section
                      color: Colors.grey[300],
                      thickness: 1,
                      indent: 0,
                      endIndent: 0,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
