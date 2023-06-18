import 'package:better_home_admin/controllers/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TechnicianReviewDetailPage extends StatefulWidget {
  const TechnicianReviewDetailPage(
      {Key? key,
      required this.reviewData,
      required this.controller,
      required this.technicianName})
      : super(key: key);
  final List<Map<String, dynamic>> reviewData;
  final String technicianName;
  final AdminController controller;

  @override
  StateMVC<TechnicianReviewDetailPage> createState() =>
      _TechnicianReviewDetailPageState();
}

class _TechnicianReviewDetailPageState
    extends StateMVC<TechnicianReviewDetailPage> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(35, 35, 35, 35),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Customer Reviews of ${widget.technicianName}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: widget.reviewData.length * 210.0,
                width: 840,
                child: ListView.builder(
                  itemCount: widget.reviewData.length,
                  itemBuilder: (context, index) {
                    final review = widget.reviewData[index];

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(22, 10, 22, 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RatingBar.builder(
                            initialRating: review['starQty'].toDouble(),
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {},
                            ignoreGestures: true,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            review['reviewText'] ?? '',
                            style: const TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
