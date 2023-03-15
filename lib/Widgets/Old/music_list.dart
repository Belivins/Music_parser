import 'package:flutter/material.dart';
import 'package:test_projects/Music/AudioHandler.dart';

class MusicList extends StatelessWidget {
  final AudioPlayerHandler audioHandler;

  const MusicList(this.audioHandler, {Key? key}) : super(key: key);

  CurrentPlay(int index) async {
    await audioHandler.skipToQueueItem(index);
    await audioHandler.play();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      child: StreamBuilder<QueueState>(
        stream: audioHandler.queueState,
        builder: (context, snapshot) {
          final queueState = snapshot.data ?? QueueState.empty;
          final queue = queueState.queue;
          return ReorderableListView.builder(
            onReorder: (int oldIndex, int newIndex) {
              // setState(() {
              if (oldIndex < newIndex) newIndex--;
              audioHandler.moveQueueItem(oldIndex, newIndex);
              // });
            },
            itemCount: queue.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                // key: ValueKey(queue[index].title),
                key: ValueKey(queue[index].id),
                color: index == queueState.queueIndex
                    ? Colors.grey.shade300
                    : null,
                child:
                ListTile(
                  title: Text(queue[index].title),
                  onTap: () => CurrentPlay(index),
                  // onTap: () => _audioHandler.skipToQueueItem(index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

//     Dismissible(
//       key: ValueKey(queue[i].id),
//       background: Container(
//         color: Colors.redAccent,
//         alignment: Alignment.centerRight,
//         child: const Padding(
//           padding: EdgeInsets.only(right: 8.0),
//           child: Icon(Icons.delete, color: Colors.white),
//         ),
//       ),
//       onDismissed: (dismissDirection) {
//         _audioHandler.removeQueueItemAt(i);
//       },
//       child: Material(
//         color: i == queueState.queueIndex
//             ? Colors.grey.shade300
//             : null,
//         child: ListTile(
//           title: Text(queue[i].title),
//           onTap: () => _audioHandler.skipToQueueItem(i),
//         ),
//       ),
//     ),
// ],