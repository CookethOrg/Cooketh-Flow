import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProjectCard extends StatelessWidget {
  final Function() onTap;
  final String flowId;
  const ProjectCard({super.key, required this.onTap, required this.flowId});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(builder: (context, pv, child) {
      // Future<ByteData> getImg() async {
      //   return await pv.createImg();
      // }

      String getFlowNameInitials() {
        // return pv.flowManager.flowName.toUpperCase().substring(0,1);
        return pv.fl.flowList[flowId]!.flowName.toUpperCase().substring(0, 1);
      }

      return InkWell(
        onTap: onTap,
        hoverColor: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        child: SizedBox(
          width: 450,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: 430,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: CircleAvatar(
                        maxRadius: 50,
                        backgroundColor: Colors.orange,
                        child: Text(
                          getFlowNameInitials(),
                          style: TextStyle(
                              fontFamily: 'Fredrick',
                              fontSize: 30,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    // child: Image.asset(
                    //     'assets/Frame 265.png',
                    //     width: double.infinity,
                    //     height: double.infinity,
                    //     fit: BoxFit.cover,
                    //   ),
                    // child: FutureBuilder<ByteData>(
                    //   future: getImg(),
                    //   builder: (context, snapshot) {
                    //     if (snapshot.connectionState == ConnectionState.waiting) {
                    //       return const Center(child: CircularProgressIndicator());
                    //     } else if (snapshot.hasError) {
                    //       return const Center(child: Icon(Icons.error));
                    //     } else if (snapshot.hasData) {
                    //       return Image(
                    //         image: MemoryImage(snapshot.data!.buffer.asUint8List()),
                    //         fit: BoxFit.cover,
                    //         width: double.infinity,
                    //         height: double.infinity,
                    //         opacity: const AlwaysStoppedAnimation<double>(0.5),
                    //       );
                    //     } else {
                    //       return const Center(child: Icon(Icons.image_not_supported));
                    //     }
                    //   },
                    // ),
                  ),
                ),
              ),

              const SizedBox(
                  height: 12), // Reduced spacing to fit within height
              SizedBox(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    pv.fl.flowList[flowId]!.flowName,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontFamily: 'Frederik', fontSize: 20),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
